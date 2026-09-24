import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_cache_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'api_service.dart';

class AssistantService {
  /// Number of agents from a freshly-loaded quick list to eagerly fetch full
  /// data for (one API call each), so their full data is cached before the
  /// user opens them.
  static const int _prefetchFullDataCount = 5;

  /// Whether the one-time [_prefetchFullDataCount]-agent prefetch has already
  /// run this session. Without this, every call to [getAssistantsQuick]
  /// (there is no de-dup on how often callers may invoke it — e.g.
  /// PupauAgentAvatar retries it on every rebuild until its assistants list
  /// is non-empty) would fire its own fresh batch of single-assistant calls,
  /// so the "5 agents" prefetch budget must be spent at most once per session
  /// rather than once per call.
  static bool _hasPrefetchedFirstFive = false;

  // Gets an assistant by its ID
  static Future<Assistant?> getAssistant(
    String assistantId,
    PupauAgentMode mode,
  ) async {
    try {
      Assistant? assistant;
      String url = ApiUrls.assistantUrl(
        assistantId,
        mode: mode,
      );
      await ApiService.call(
        url,
        RequestType.get,
        onSuccess: (response) async {
          // A Living Agent payload is a different aggregate and must not go
          // through the assistant mapping.
          final Assistant parsed = mode == PupauAgentMode.livingAgent
              ? Assistant.fromLivingAgentMap(response.data)
              : Assistant.fromMap(response.data);
          assistant = parsed;
          // Living Agents stay out of the cache. The key is derived from the
          // assistant type, so storing one would file it under the plain
          // assistant prefix and it could later be served to an assistant
          // chat with the same id.
          if (mode != PupauAgentMode.livingAgent) {
            await AssistantCacheService.put(parsed);
          }
        },
      );
      return assistant;
    } catch (e, stackTrace) {
      // A null return here lands in the chat as the generic ApiErrorWidget,
      // with nothing saying why. Log before collapsing it: a mapping TypeError
      // and an unreachable backend produce the very same blank error screen.
      debugPrint(
        "[AssistantService] getAssistant failed "
        "(id=$assistantId, mode=${mode.name}): $e\n$stackTrace",
      );
      return null;
    }
  }

  static Future<List<Assistant>> getAssistantsQuick() async {
    try {
      List<Assistant> quickAssistants = [];
      await ApiService.call(
        ApiUrls.getAssistantsQuickUrl,
        RequestType.get,
        onSuccess: (response) async {
          quickAssistants = assistantsFromMap(
            jsonEncode(response.data["items"]),
          );
        },
      );
      // The quick list only carries basic info, so it is never written to
      // AssistantCacheService directly — only the first _prefetchFullDataCount
      // agents get cached, and only via a full single-assistant call each,
      // and only the first time this session (see _hasPrefetchedFirstFive).
      if (!_hasPrefetchedFirstFive) {
        _hasPrefetchedFirstFive = true;
        _prefetchFullAssistantData(quickAssistants);
      }
      return quickAssistants;
    } catch (e) {
      return [];
    }
  }

  /// Eagerly (fire-and-forget) fetches full data for the first
  /// [_prefetchFullDataCount] agents of a freshly-loaded quick list, one API
  /// call per agent. Does not block the quick list response; each fetch
  /// caches itself via [getAssistant]. Only ever runs once per session — see
  /// [_hasPrefetchedFirstFive].
  static void _prefetchFullAssistantData(List<Assistant> assistantsList) {
    for (final Assistant quick in assistantsList.take(_prefetchFullDataCount)) {
      getAssistant(
        quick.id,
        quick.type == AssistantType.marketplace
            ? PupauAgentMode.marketplace
            : PupauAgentMode.assistant,
      );
    }
  }

  // Gets an assistant image URL by its ID, image UUID, and format
  static String getAssistantImageUrl(
    String assistantId,
    String imageUuid,
    PupauAgentMode mode,
    ImageFormat format,
  ) {
    try {
      if (imageUuid.isEmpty) return getAssistantFallbackImage(assistantId);
      final String stagingUrl = "https://api-staging.pupau.ai";
      final String formatString = getImageFormatString(format);
      final String target = mode == PupauAgentMode.marketplace ? "/marketplace" : "";
      // /dev/ is only correct for the staging host - every other apiUrl
      // (the official host, or any custom/tenant apiUrl e.g. a VPN tunnel)
      // is a production tenant and must use /prod/.
      final String env = ApiUrls.apiUrl == stagingUrl ? "dev" : "prod";
      final bool isOfficialOrStaging =
          ApiUrls.apiUrl == ApiUrls.defaultApiUrl ||
          ApiUrls.apiUrl == stagingUrl;
      final String resolvedUrl;
      if (isOfficialOrStaging) {
        resolvedUrl =
            "https://cdn.pupau.ai$target/assistants/$env/$assistantId/$imageUuid-$formatString.jpg";
      } else {
        String baseUrl = "${ApiUrls.apiUrl}/local/files/public";
        resolvedUrl =
            "$baseUrl$target/assistants/$env/$assistantId/$imageUuid-$formatString.jpg";
      }
      return resolvedUrl;
    } catch (e) {
      return getAssistantFallbackImage(assistantId);
    }
  }

  // Gets an assistant fallback image by its ID
  static String getAssistantFallbackImage(String assistantId) {
    String idLowerCase = assistantId.toLowerCase();
    int asciiSum = idLowerCase.codeUnits.fold(0, (sum, char) => sum + char);
    int imageNumber = (asciiSum % 7) + 1;
    return "${Constants.assetPath}/avatars/fallback_avatar_$imageNumber.jpg";
  }

  // Gets an image format string by its format
  static String getImageFormatString(ImageFormat format) {
    switch (format) {
      case ImageFormat.low:
        return "L";
      case ImageFormat.medium:
        return "M";
      case ImageFormat.high:
        return "H";
    }
  }

  static AssistantType getAssistantTypeEnum(String type) {
    switch (type.toLowerCase()) {
      case "assistant":
        return AssistantType.assistant;
      case "marketplace":
        return AssistantType.marketplace;
      default:
        return AssistantType.assistant;
    }
  }

  static String getAssistantTypeString(AssistantType type) {
    switch (type) {
      case AssistantType.assistant:
        return "ASSISTANT";
      case AssistantType.marketplace:
        return "MARKETPLACE";
    }
  }

  static ReplyMode getReplyModeEnum(String replyMode) {
    switch (replyMode) {
      case "open":
        return ReplyMode.open;
      case "closed":
        return ReplyMode.closed;
      case "hybrid":
        return ReplyMode.hybrid;
      default:
        return ReplyMode.open;
    }
  }

  static IconData getCapabilityImage(String capability) {
    switch (capability) {
      case "TEXT":
        return Symbols.subject;
      case "IMAGE":
        return Symbols.compare;
      case "ATTACHMENT":
        return Symbols.attach_file;
      case "ANONYMOUS":
        return Symbols.visibility_off;
      case "TAG":
        return Symbols.alternate_email;
      case "VIDEO":
        return Symbols.videocam;
      case "AUDIO":
        return Symbols.volume_up;
      case "VISIBILITY_USER":
        return Symbols.person;
      case "VISIBILITY_ORGANIZATION":
        return Symbols.domain;
      case "TOOL_USE":
        return Symbols.construction;
      default:
        return Symbols.question_mark;
    }
  }

  static String getCapabilityName(String capability) {
    switch (capability) {
      case "TEXT":
        return Strings.text.tr;
      case "IMAGE":
        return Strings.imagesReading.tr;
      case "ATTACHMENT":
        return Strings.attachments.tr;
      case "ANONYMOUS":
        return Strings.anonymousSessions.tr;
      case "TAG":
        return Strings.tag.tr;
      case "VIDEO":
        return Strings.video.tr;
      case "AUDIO":
        return Strings.audio.tr;
      case "VISIBILITY_USER":
        return Strings.visibilityUser.tr;
      case "VISIBILITY_ORGANIZATION":
        return Strings.visibilityOrganization.tr;
      case "TOOL_USE":
        return Strings.toolUse.tr;
      default:
        return capability;
    }
  }

  static List<String> getCapabilities(Assistant assistant) {
    List<String> capabilities = assistant.capabilities;
    UsageSettings? usageSettings = assistant.usageSettings;
    if (usageSettings != null) {
      capabilities.addIf(usageSettings.canAttach, "ATTACHMENT");
      capabilities.addIf(usageSettings.canTag, "TAG");
      capabilities.addIf(
        usageSettings.chatVisibility == ChatVisibility.user,
        "VISIBILITY_USER",
      );
      capabilities.addIf(
        usageSettings.chatVisibility == ChatVisibility.organization,
        "VISIBILITY_ORGANIZATION",
      );
      capabilities.addIf(usageSettings.canAnonymous, "ANONYMOUS");
    }
    if (assistant.model?.canUseTools ?? false) capabilities.add("TOOL_USE");

    return capabilities;
  }
}

enum ImageFormat { low, medium, high }
