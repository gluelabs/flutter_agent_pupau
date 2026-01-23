import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

List<CustomAction> customActionsFromJson(String str) => List<CustomAction>.from(
    json.decode(str).map((x) => CustomAction.fromJson(x)));

class CustomAction {
  CustomActionType type;
  String userLabel;
  String userDescription;
  CustomActionSetting? setting;
  String idTarget;
  String id;

  CustomAction({
    required this.type,
    required this.userLabel,
    required this.userDescription,
    required this.setting,
    required this.idTarget,
    required this.id,
  });

  factory CustomAction.fromJson(Map<String, dynamic> json) => CustomAction(
        type:
            customActionTypeFromString(json["type"] ?? ""),
        userLabel: json["userLabel"] ?? "",
        userDescription: json["userDescription"] ?? "",
        setting: CustomActionSetting.fromJson(json["setting"] ?? {}),
        idTarget: json["idTarget"] ?? "",
        id: json["id"] ?? "",
      );

  IconData? get icon {
    switch (type) {
      case CustomActionType.prompt:
        return Symbols.quickreply;
      case CustomActionType.assistant:
        return Symbols.support_agent;
      case CustomActionType.interactiveAction:
        return Symbols.touch_app;
      case CustomActionType.actor:
        return Symbols.cinematic_blur;
    }
  }
}

class CustomActionSetting {
  String? prompt;
  bool? attachment;
  bool? shareMessages;
  int? messageCount;
  String? assistantId;
  AssistantType? assistantType;

  CustomActionSetting({
    required this.prompt,
    this.attachment,
    this.shareMessages,
    this.messageCount,
    this.assistantId,
    this.assistantType,
  });

  factory CustomActionSetting.fromJson(Map<String, dynamic> json) =>
      CustomActionSetting(
        prompt: json["prompt"],
        attachment: json["attachment"],
        shareMessages: json["shareMessages"],
        messageCount: json["messageCount"] == null
            ? null
            : getInt(json["messageCount"]),
        assistantId: json["assistantId"],
        assistantType: json["assistantType"] == null
            ? null
            : AssistantService.getAssistantTypeEnum(json["assistantType"]),
      );

}

enum CustomActionType { prompt, assistant, interactiveAction, actor }

CustomActionType customActionTypeFromString(String type) {
  switch (type.toUpperCase()) {
    case "PROMPT":
      return CustomActionType.prompt;
    case "ASSISTANT":
      return CustomActionType.assistant;
    case "INTERACTIVE_ACTION":
      return CustomActionType.interactiveAction;
    case "ACTOR":
      return CustomActionType.actor;
    default:
      return CustomActionType.prompt;
  }
}
