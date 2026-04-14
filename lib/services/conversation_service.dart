import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:uuid/uuid.dart';

class ConversationService {
  /// Creates a new conversation for the given assistant
  static Future<PupauConversation?> createConversation(
    String assistantId,
    bool isMarketplace, {
    bool isAnonymous = false,
  }) async {
    try {
      PupauConversation? conversation;
      final String url = ApiUrls.conversationsUrl(
        assistantId,
        isMarketplace: isMarketplace,
      );
      if (isAnonymous) {
        PupauSharedPreferences.deleteAnonymousConversationKey();
        final String anonymousConversationKey = Uuid().v4();
        PupauSharedPreferences.setAnonymousConversationKey(
          anonymousConversationKey,
        );
      }
      await ApiService.call(
        url,
        RequestType.post,
        data: {
          "title": "New Conversation",
          "source": "INTEGRATION",
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
    bool isMarketplace,
  ) async {
    try {
      PupauConversation? conversation;
      String url = ApiUrls.conversationUrl(
        idAssistant,
        idConversation,
        isMarketplace: isMarketplace,
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
                  "assistantType": isMarketplace ? "MARKETPLACE" : "ASSISTANT",
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
                  "assistantType": isMarketplace ? "MARKETPLACE" : "ASSISTANT",
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
            "assistantType": isMarketplace ? "MARKETPLACE" : "ASSISTANT",
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
    bool isMarketplace,
  ) async {
    try {
      PupauConversation? conversation;
      String url = ApiUrls.conversationUrl(
        idAssistant,
        idConversation,
        isMarketplace: isMarketplace,
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
    bool isMarketplace,
    PupauConversation conversation,
  ) async {
    try {
      bool success = false;
      String url = ApiUrls.conversationUrl(
        conversation.assistantId,
        conversation.id,
        isMarketplace: isMarketplace,
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
    bool isMarketplace,
  ) async {
    try {
      PupauConversation? conversation;
      Map<String, dynamic> body = {"title": title, "lastQueryId": queryId};
      await ApiService.call(
        ApiUrls.forkConversationUrl(
          assistantId,
          conversationId,
          isMarketplace: isMarketplace,
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
