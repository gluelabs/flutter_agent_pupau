import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'api_service.dart';

class AssistantService {
  // Gets an assistant by its ID
  static Future<Assistant?> getAssistant(String assistantId, bool isMarketplace) async {
    try {
      Assistant? assistant;
      String url = ApiUrls.assistantUrl(assistantId, isMarketplace: isMarketplace);
      await ApiService.call(
        url,
        RequestType.get,
        onSuccess: (response) {
          assistant = Assistant.fromMap(response.data);
        },
      );
      return assistant;
    } catch (e) {
      return null;
    }
  }

  static Future<List<Assistant>> getAssistantsQuick() async {
    try {
      List<Assistant> quickAssistants = [];
      await ApiService.call(
        ApiUrls.getAssistantsQuickUrl,
        RequestType.get,
        onSuccess: (response) => quickAssistants = assistantsFromMap(
          jsonEncode(response.data["items"]),
        ),
      );
      return quickAssistants;
    } catch (e) {
      return [];
    }
  }

  // Gets an assistant image URL by its ID, image UUID, and format
  static String getAssistantImageUrl(
    String assistantId,
    String imageUuid,
    bool isMarketplace,
    ImageFormat format,
  ) {
    try {
      if (imageUuid.isEmpty) return getAssistantFallbackImage(assistantId);
      String formatString = getImageFormatString(format);
      String target = isMarketplace ? "/marketplace" : "";
      return "https://cdn.pupau.ai$target/assistants/prod/$assistantId/$imageUuid-$formatString.jpg";
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
      capabilities.addIf(usageSettings.chatVisibility == ChatVisibility.user,
          "VISIBILITY_USER");
      capabilities.addIf(
          usageSettings.chatVisibility == ChatVisibility.organization,
          "VISIBILITY_ORGANIZATION");
      capabilities.addIf(usageSettings.canAnonymous, "ANONYMOUS");
    }
    if (assistant.model?.canUseTools ?? false) capabilities.add("TOOL_USE");

    return capabilities;
  }
}

enum ImageFormat { low, medium, high }
