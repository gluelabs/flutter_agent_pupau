import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/services/ui_tool_service.dart';

class UiToolMessage {
  String id;
  UiToolType type;
  UiToolData data;
  String assistantName;
  String? imageUuid;
  String? chatBotId;
  String? marketPlaceId;
  String queryGroupId;

  UiToolMessage({
    required this.id,
    required this.type,
    required this.data,
    required this.assistantName,
    this.imageUuid,
    this.chatBotId,
    this.marketPlaceId,
    required this.queryGroupId,
  });

  factory UiToolMessage.fromJson(Map<String, dynamic> json) => UiToolMessage(
        id: json["id"] ?? "",
        type: UiToolService.getUiToolTypeEnum(json["type"] ?? ""),
        data: UiToolData.fromJson(json["data"] ?? {}),
        assistantName: json["assistantName"] ?? "",
        imageUuid: json["imageUuid"],
        chatBotId: json["chatBotId"],
        marketPlaceId: json["marketPlaceId"],
        queryGroupId: json["queryGroupId"] ?? "",
      );
}

class UiToolData {
  String toolType;
  String toolId;
  String toolName;
  String toolCallbackId;
  String message;
  ToolParameterType? credentialPropertyType;
  List<String> scopes;
  Map<String, dynamic> toolRequestData;

  UiToolData({
    required this.toolType,
    required this.toolId,
    required this.toolName,
    required this.toolCallbackId,
    required this.message,
    required this.credentialPropertyType,
    required this.scopes,
    required this.toolRequestData,
  });

  factory UiToolData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> toolRequestData = {};
    try {
      toolRequestData = Map<String, dynamic>.from(json["toolRequestData"]);
    } catch (e) {
      toolRequestData = {};
    }
    return UiToolData(
        toolType: json["toolType"] ?? "",
        toolId: json["toolId"] ?? "",
        toolName: json["toolName"] ?? "",
        toolCallbackId: json["toolCallbackId"] ?? "",
        message: json["message"] ?? "",
        credentialPropertyType: json["credentialPropertyType"] == null
            ? null
            : ToolUseService.getToolUseParameterTypeEnum(
                json["credentialPropertyType"]),
        scopes: (json["scopes"] is List
            ? List<String>.from((json["scopes"] as List)
                .where((x) => x != null)
                .map((x) => x.toString()))
            : []),
        toolRequestData: toolRequestData);
  }
}
