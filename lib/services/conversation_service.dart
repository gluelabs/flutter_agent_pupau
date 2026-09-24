import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:uuid/uuid.dart';

/// The `GET /living-agents/:id/conversations/:conversationId` payload.
///
/// A Living Agent transcript is an envelope, not a conversation: the
/// conversation sits under `conversation`, the history under `messages`, and
/// there is no paginated `queries` listing to fall back on — the backend
/// serves that route as SSE only. So this is the one and only source of a
/// Living Agent's history.
class LivingAgentTranscript {
  final PupauConversation conversation;

  /// Raw history rows, oldest first. Shaped like REST history rows except the
  /// user turn is `question` rather than `query` (both are read by
  /// [PupauMessage.fromLoadedChat]).
  final List<dynamic> messages;

  /// `idle | running | done | stopped | error` — state of the LAST run.
  /// Empty when the backend omitted it: never render an invented state.
  final String runState;

  /// Exclusive cursor for the reattach stream; null when no run is live.
  final String? resumeEventId;

  const LivingAgentTranscript({
    required this.conversation,
    required this.messages,
    required this.runState,
    required this.resumeEventId,
  });

  bool get isRunning => runState == 'running';

  factory LivingAgentTranscript.fromMap(Map<String, dynamic> json) {
    final dynamic rawConversation = json['conversation'];
    final dynamic rawMessages = json['messages'];
    return LivingAgentTranscript(
      conversation: PupauConversation.fromMap(
        rawConversation is Map
            ? Map<String, dynamic>.from(rawConversation)
            : <String, dynamic>{},
      ),
      messages: rawMessages is List ? rawMessages : const <dynamic>[],
      runState: getString(json['runState']),
      resumeEventId: json['resumeEventId'] == null
          ? null
          : getString(json['resumeEventId']),
    );
  }
}

class ConversationService {
  /// Loads a Living Agent conversation transcript.
  ///
  /// Kept apart from [getConversation]: that one maps the response body
  /// straight into a [PupauConversation], which on this envelope yields a
  /// conversation with an empty id and an empty chat.
  static Future<LivingAgentTranscript?> getLivingAgentTranscript(
    String idAgent,
    String idConversation,
  ) async {
    try {
      LivingAgentTranscript? transcript;
      await ApiService.call(
        ApiUrls.conversationUrl(
          idAgent,
          idConversation,
          mode: PupauAgentMode.livingAgent,
        ),
        RequestType.get,
        onSuccess: (response) => transcript = LivingAgentTranscript.fromMap(
          Map<String, dynamic>.from(response.data as Map),
        ),
        onError: (error) {
          showErrorSnackbar(
            error.statusCode == 403
                ? Strings.conversationForbidden.tr
                : Strings.conversationLoadFailed.tr,
          );
          PupauEventService.instance.emitPupauEvent(
            PupauEvent(
              type: UpdateConversationType.error,
              payload: {
                "error": error.statusCode == 403
                    ? "Conversation forbidden"
                    : "Conversation load failed",
                "assistantId": idAgent,
                "agentMode": PupauAgentMode.livingAgent.name,
                "conversationId": idConversation,
              },
            ),
          );
        },
      );
      return transcript;
    } catch (e, stackTrace) {
      debugPrint(
        "[ConversationService] getLivingAgentTranscript failed "
        "(agent=$idAgent, conversation=$idConversation): $e\n$stackTrace",
      );
      return null;
    }
  }

  static String? _hostPackageName;

  /// Client-asserted conversation source for the create-conversation endpoint.
  ///
  /// Web is always `WEB`. On Android/iOS the value is `ANDROID`/`IOS` when the
  /// plugin runs inside the official Pupau app
  /// ([Constants.officialAppPackageName]), and `ANDROID_PLUGIN`/`IOS_PLUGIN`
  /// when it is embedded in any other host app.
  static Future<String> _clientSource() async {
    if (kIsWeb) return "WEB";
    if (!Platform.isAndroid && !Platform.isIOS) return "WEB";

    final String base = Platform.isAndroid ? "ANDROID" : "IOS";
    try {
      _hostPackageName ??= (await PackageInfo.fromPlatform()).packageName;
    } catch (_) {
      _hostPackageName = null;
    }
    final bool isOfficialApp =
        _hostPackageName == Constants.officialAppPackageName;
    return isOfficialApp ? base : "${base}_PLUGIN";
  }

  /// Creates a new conversation for the given assistant
  static Future<PupauConversation?> createConversation(
    String assistantId,
    PupauAgentMode mode, {
    bool isAnonymous = false,
  }) async {
    try {
      PupauConversation? conversation;
      final String url = ApiUrls.conversationsUrl(
        assistantId,
        mode: mode,
      );
      if (isAnonymous) {
        PupauSharedPreferences.deleteAnonymousConversationKey();
        final String anonymousConversationKey = Uuid().v4();
        PupauSharedPreferences.setAnonymousConversationKey(
          anonymousConversationKey,
        );
      }
      final String source = await _clientSource();
      await ApiService.call(
        url,
        RequestType.post,
        data: {
          "title": "New Conversation",
          "source": source,
          "data": "",
          if (isAnonymous)
            "encryptionPass":
                PupauSharedPreferences.getAnonymousConversationKey(),
        },
        onSuccess: (response) =>
            conversation = PupauConversation.fromMap(response.data),
      );
      return conversation;
    } catch (e) {
      return null;
    }
  }

  /// Gets a conversation by its assistant and conversation IDs
  static Future<PupauConversation?> getConversation(
    String idAssistant,
    String idConversation,
    PupauAgentMode mode,
  ) async {
    try {
      PupauConversation? conversation;
      String url = ApiUrls.conversationUrl(
        idAssistant,
        idConversation,
        mode: mode,
      );
      await ApiService.call(
        url,
        RequestType.get,
        onSuccess: (response) =>
            conversation = PupauConversation.fromMap(response.data),
        onError: (error) {
          if (error.statusCode == 403) {
            showErrorSnackbar(Strings.conversationForbidden.tr);
            String errorMessage = "Conversation forbidden";
            PupauEventService.instance.emitPupauEvent(
              PupauEvent(
                type: UpdateConversationType.error,
                payload: {
                  "error": errorMessage,
                  "assistantId": idAssistant,
                  "assistantType": mode == PupauAgentMode.marketplace ? "MARKETPLACE" : "ASSISTANT",
                  "conversationId": idConversation,
                },
              ),
            );
          } else {
            showErrorSnackbar(Strings.conversationLoadFailed.tr);
            String errorMessage = "Conversation load failed";
            PupauEventService.instance.emitPupauEvent(
              PupauEvent(
                type: UpdateConversationType.error,
                payload: {
                  "error": errorMessage,
                  "assistantId": idAssistant,
                  "assistantType": mode == PupauAgentMode.marketplace ? "MARKETPLACE" : "ASSISTANT",
                  "conversationId": idConversation,
                },
              ),
            );
          }
        },
      );
      return conversation;
    } catch (e) {
      showErrorSnackbar(Strings.conversationLoadFailed.tr);
      String errorMessage = "Conversation load failed";
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": errorMessage,
            "assistantId": idAssistant,
            "assistantType": mode == PupauAgentMode.marketplace ? "MARKETPLACE" : "ASSISTANT",
            "conversationId": idConversation,
          },
        ),
      );
      return null;
    }
  }

  /// Updates a conversation by its assistant and conversation IDs
  static Future<PupauConversation?> updateConversation(
    String idAssistant,
    String idConversation,
    Map<String, dynamic> data,
    PupauAgentMode mode,
  ) async {
    try {
      PupauConversation? conversation;
      String url = ApiUrls.conversationUrl(
        idAssistant,
        idConversation,
        mode: mode,
      );
      await ApiService.call(
        url,
        RequestType.patch,
        data: data,
        onSuccess: (response) =>
            conversation = PupauConversation.fromMap(response.data),
      );
      return conversation;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> deleteConversation(
    PupauAgentMode mode,
    PupauConversation conversation,
  ) async {
    try {
      bool success = false;
      String url = ApiUrls.conversationUrl(
        conversation.assistantId,
        conversation.id,
        mode: mode,
      );
      await ApiService.call(
        url,
        RequestType.delete,
        onSuccess: (response) => success = true,
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  /// Forks a conversation by its assistant and conversation IDs
  static Future<PupauConversation?> forkConversation(
    String assistantId,
    String conversationId,
    String title,
    String queryId,
    PupauAgentMode mode,
  ) async {
    try {
      PupauConversation? conversation;
      Map<String, dynamic> body = {"title": title, "lastQueryId": queryId};
      await ApiService.call(
        ApiUrls.forkConversationUrl(
          assistantId,
          conversationId,
          mode: mode,
        ),
        RequestType.post,
        data: body,
        onSuccess: (response) =>
            conversation = PupauConversation.fromMap(response.data),
      );
      return conversation;
    } catch (e) {
      return null;
    }
  }

  /// Gets a favicon URL
  static String getFaviconUrl(String link) =>
      "https://www.google.com/s2/favicons?domain=${Uri.parse(link).host}&sz=128";

  static bool isDifferentDay(DateTime? firstDate, DateTime? secondDate) {
    if (firstDate == null || secondDate == null) return false;
    String? firstDateString =
        firstDate.day.toString() +
        firstDate.month.toString() +
        firstDate.year.toString();
    String? secondDateString =
        secondDate.day.toString() +
        secondDate.month.toString() +
        secondDate.year.toString();
    return firstDateString != secondDateString;
  }

  static AttachmentType getAttachmentTypeEnum(String attachmentType) {
    switch (attachmentType) {
      case "WEBPAGETEXT":
        return AttachmentType.webpageText;
      case "WEBPAGECODE":
        return AttachmentType.webpageCode;
      default:
        return AttachmentType.webpageText;
    }
  }

  static MessageType? getMessageTypeEnum(String? messageType) {
    if (messageType == null) return null;
    switch (messageType.toLowerCase()) {
      case "kb":
        return MessageType.kb;
      case "memory":
        return MessageType.memory;
      case "error":
        return MessageType.error;
      case "forbidden":
        return MessageType.forbidden;
      case "no_document":
        return MessageType.noDocument;
      case "web_based":
        return MessageType.webBased;
      case "websearch":
        return MessageType.webSearch;
      case "websearch_query":
        return MessageType.webSearchQuery;
      case "websearch_info":
        return MessageType.webSearchInfo;
      case "layer_message":
        return MessageType.layerMessage;
      case "layer_response":
        return MessageType.layerResponse;
      case "tool_use_start":
        return MessageType.toolUseStart;
      case "native_tools":
        return MessageType.nativeTools;
      case "tool_pending":
        return MessageType.toolPending;
      case "tool_args_delta":
        return MessageType.toolArgsDelta;
      case "tool_heartbeat":
        return MessageType.toolHeartbeat;
      case "tool_evaluation":
        return MessageType.toolEvaluation;
      case "tool_partial_result":
        return MessageType.toolPartialResult;
      case "no_vision_capability":
        return MessageType.noVisionCapability;
      case "retry":
        return MessageType.retry;
      case "conversation_title_generated":
        return MessageType.conversationTitleGenerated;
      case "audio_input_transcription":
        return MessageType.audioInputTranscription;
      case "attachment_trimming":
      case "emergency_trimming":
        return MessageType.attachmentTrimming;
      case "heartbeat":
        return MessageType.heartbeat;
      case "skill_loaded":
        return MessageType.skillLoaded;
      case "skill_unloaded":
        return MessageType.skillUnloaded;
      case "grounding_verification":
        return MessageType.groundingVerification;
      default:
        return null;
    }
  }

  static SourceType getSourceTypeEnum(String? sourceType) {
    switch (sourceType?.toLowerCase()) {
      case "llm":
        return SourceType.llm;
      case "tool_use":
      case "tool-use":
        return SourceType.toolUse;
      case "ui_tool":
      case "ui-tool":
        return SourceType.uiTool;
      case "event":
        return SourceType.event;
      default:
        return SourceType.llm;
    }
  }

  static IconData getWebSearchTypeIcon(WebSearchType webSearchType) {
    switch (webSearchType) {
      case WebSearchType.webSearch:
        return Symbols.travel_explore;
      case WebSearchType.imageSearch:
        return Symbols.image_search;
      case WebSearchType.newsSearch:
        return Symbols.quick_reference_all;
    }
  }


  static String getNoVisionCapabilityMessage() {
    String pixtralTag =
        "<assistant id='oobW1' type='MARKETPLACE' name='Pixtral 12B'>Pixtral 12B</assistant>";
    String claudeTag =
        "<assistant id='MZNYc' type='MARKETPLACE' name='Claude Sonnet 3.7'>Claude Sonnet 3.7</assistant>";
    String options =
        '''
      <options>
        <option prompt="${Strings.whatDoYouSee.tr} $pixtralTag">
          ${Strings.retryWith.tr} Pixtral
        </option>
        <option prompt="${Strings.whatDoYouSee.tr} $claudeTag">
          ${Strings.retryWith.tr} Claude Sonnet 3.7
        </option>
      </options>
    ''';
    return Strings.noVisionCapability.tr + options;
  }

  static Reaction getReactionEnum(String reaction) {
    switch (reaction) {
      case "NONE":
        return Reaction.none;
      case "LIKE":
        return Reaction.like;
      case "DISLIKE":
        return Reaction.dislike;
      default:
        return Reaction.none;
    }
  }

  static String getReactionString(Reaction reaction) {
    switch (reaction) {
      case Reaction.none:
        return "NONE";
      case Reaction.like:
        return "LIKE";
      case Reaction.dislike:
        return "DISLIKE";
    }
  }

  static WebSearchType? getWebSearchTypeEnum(String? searchType) {
    if (searchType == null) return null;
    switch (searchType.toLowerCase()) {
      case "web":
        return WebSearchType.webSearch;
      case "images":
        return WebSearchType.imageSearch;
      case "news":
        return WebSearchType.newsSearch;
      default:
        return WebSearchType.webSearch;
    }
  }

  /// User-friendly label for attachment trimming reason (optional).
  static String getAttachmentTrimmingReasonLabel(String reason) {
    switch (reason.toLowerCase()) {
      case "proportional_share":
        return Strings.attachmentTrimmingReasonProportionalShare.tr;
      case "fallback_over_budget":
        return Strings.attachmentTrimmingReasonFallbackOverBudget.tr;
      case "over_budget":
        return Strings.attachmentTrimmingReasonOverBudget.tr;
      case "below_min_useful":
        return Strings.attachmentTrimmingReasonBelowMinUseful.tr;
      default:
        return reason.isNotEmpty ? reason : "—";
    }
  }
}
