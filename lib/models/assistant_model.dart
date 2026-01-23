import 'dart:convert';
import 'package:flutter_agent_pupau/models/ai_model.dart';
import 'package:flutter_agent_pupau/models/assistant_api_key_model.dart';
import 'package:flutter_agent_pupau/models/custom_action_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/settings.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

List<Assistant> assistantsFromMap(String str) =>
    List<Assistant>.from(json.decode(str).map((x) => Assistant.fromMap(x)));

class Assistant {
  String id;
  String name;
  String description;
  String imageUuid;
  String welcomeMessage;
  UsageSettings? usageSettings;
  KBSettings? kbSettings;
  List<CustomAction> customActions;
  AssistantType type;
  ReplyMode replyMode;
  AiModel? model;
  String costMessage;
  List<String> capabilities;
  AssistantApiKeyConfig? apiKeyConfig;

  Assistant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUuid,
    required this.welcomeMessage,
    this.usageSettings,
    this.kbSettings,
    required this.customActions,
    required this.type,
    required this.replyMode,
    this.model,
    this.costMessage = "",
    this.capabilities = const [],
    this.apiKeyConfig,
  });

  factory Assistant.fromMap(Map<String, dynamic> json) => Assistant(
    id: getString(json["id"]),
    name: getString(json["name"]),
    description: getString(json["description"]),
    imageUuid: getString(json["imageUuid"]),
    welcomeMessage: getString(json["welcomeMessage"]),
    usageSettings: json["assistantSettings"]?["settings"] != null
        ? UsageSettings.fromMap(json["assistantSettings"]?["settings"])
        : null,
    kbSettings: json["assistantSettings"]?["kbSettings"] != null
        ? KBSettings.fromMap(json["assistantSettings"]?["kbSettings"])
        : null,
    customActions: json["assistantSettings"]?["customActions"] != null
        ? (json["assistantSettings"]?["customActions"] as List<dynamic>)
              .map((e) => CustomAction.fromJson(e))
              .toList()
        : [],
    type: AssistantService.getAssistantTypeEnum(
      json["type"] ?? json["assistantType"] ?? "",
    ),
    replyMode: AssistantService.getReplyModeEnum(json["replyMode"] ?? "open"),
    model: json["aiModel"] != null ? AiModel.fromJson(json["aiModel"]) : null,
    costMessage: json["costMessage"] ?? json["cost"]?["message"] ?? "",
    capabilities: json["capabilities"] != null
        ? (json["capabilities"] as List<dynamic>)
              .map((e) => e.toString())
              .toList()
        : [],
    apiKeyConfig: json["apiKeyConfiguration"] != null
        ? AssistantApiKeyConfig.fromJson(json["apiKeyConfiguration"])
        : null,
  );
}

class UsageSettings {
  bool canAttach;
  bool canTag;
  ChatSharing canShare;
  bool canWebSearch;
  bool actionBarAlwaysVisible;
  bool canAnonymous;
  ChatVisibility chatVisibility;

  UsageSettings({
    required this.canAttach,
    required this.canTag,
    required this.canShare,
    required this.canWebSearch,
    required this.actionBarAlwaysVisible,
    required this.canAnonymous,
    required this.chatVisibility,
  });

  factory UsageSettings.fromMap(Map<String, dynamic> json) => UsageSettings(
    canAttach:
        json[Settings.settingAttachmentId]?[Settings.settingEnableName] ??
        false,
    canTag:
        json[Settings.settingMultiTagId]?[Settings.settingEnableName] ?? false,
    canShare: getChatSharingEnum(
      json[Settings.settingShareId]?[Settings.settingShareName] ?? "",
    ),
    canWebSearch:
        json[Settings.settingSearchEngineUseId]?[Settings.settingEnableName] ??
        false,
    actionBarAlwaysVisible:
        json[Settings.settingActionBarAlwaysVisibleId]?[Settings
            .settingEnableName] ??
        true,
    canAnonymous:
        json[Settings.settingAnonymousSessionsId]?[Settings
            .settingEnableName] ??
        false,
    chatVisibility: getChatVisibilityEnum(
      json[Settings.settingChatVisibilityId]?[Settings
              .settingChatVisibilityName] ??
          "",
    ),
  );

  static ChatSharing getChatSharingEnum(String chatSharing) {
    switch (chatSharing) {
      case "PUBLIC":
        return ChatSharing.public;
      case "COMPANY":
        return ChatSharing.organization;
      case "NONE":
        return ChatSharing.none;
      default:
        return ChatSharing.none;
    }
  }

  static ChatVisibility getChatVisibilityEnum(String chatVisibility) {
    switch (chatVisibility) {
      case "ORGANIZATION":
        return ChatVisibility.organization;
      case "USER":
        return ChatVisibility.user;
      case "ANONYMOUS":
        return ChatVisibility.anonymous;
      default:
        return ChatVisibility.user;
    }
  }

  static String getChatVisibilityString(ChatVisibility chatVisibility) {
    switch (chatVisibility) {
      case ChatVisibility.organization:
        return Strings.organization.tr;
      case ChatVisibility.user:
        return Strings.user.tr;
      case ChatVisibility.anonymous:
        return Strings.anonymous.tr;
    }
  }
}

class KBSettings {
  bool showKbChip;
  bool showKbResources;
  bool enableKbDownload;

  KBSettings({
    required this.showKbChip,
    required this.showKbResources,
    required this.enableKbDownload,
  });

  factory KBSettings.fromMap(Map<String, dynamic> json) => KBSettings(
    showKbChip: getBool(json["assistantShowKbMatch"]?["enable"]),
    showKbResources: getBool(json["assistantShowKbResources"]?["enable"]),
    enableKbDownload: getBool(json["assistantKbResourcesDownload"]?["enable"]),
  );
}

enum ChatSharing { public, organization, none }

enum AssistantType { assistant, marketplace }

enum ReplyMode { open, closed, hybrid }

enum ChatVisibility { organization, user, anonymous }
