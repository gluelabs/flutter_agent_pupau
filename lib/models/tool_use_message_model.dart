import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_thinking_data.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_image_generation_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_knowledge_base_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_pipeline_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_s_m_t_p_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_to_do_list_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_web_reader_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_web_search_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
class ToolUseMessage {
  String id;
  String? messageId;
  String assistantName;
  String? imageUuid;
  String? chatBotId;
  String? marketPlaceId;
  ToolUseType type;
  String toolName;
  String queryGroupId;
  bool showTool;
  String toolMessage;
  Map<String, dynamic>? nativeToolData;
  ToolUsePipelineData? pipelineData;
  Map<String, dynamic>? remoteCallData;
  ToolUseThinkingData? thinkingData;
  ToolUseToDoListData? toDoListData;
  ToolUseWebSearchData? webSearchData;
  ToolUseKnowledgeBaseData? knowledgeBaseData;
  ToolUseDocumentData? documentData;
  ToolUseSMTPData? smtpData;
  ToolUseImageGenerationData? imageGenerationData;
  ToolUseBrowserUseData? browserUseData;
  ToolUseAskUserData? askUserData;
  ToolUseWebReaderData? webReaderData;

  ToolUseMessage({
    required this.id,
    this.messageId,
    required this.assistantName,
    this.imageUuid,
    this.chatBotId,
    this.marketPlaceId,
    required this.type,
    required this.toolName,
    required this.queryGroupId,
    this.showTool = true,
    this.toolMessage = "",
    this.nativeToolData,
    this.pipelineData,
    this.remoteCallData,
    this.thinkingData,
    this.toDoListData,
    this.webSearchData,
    this.knowledgeBaseData,
    this.documentData,
    this.smtpData,
    this.imageGenerationData,
    this.browserUseData,
    this.askUserData,
    this.webReaderData,
  });

  factory ToolUseMessage.fromJsonSSE(Map<String, dynamic> json) {
    ToolUseType type = ToolUseService.getToolUseTypeEnum(json["type"] ?? "",
        nativeToolType: json["typeDetails"]?["nativeTool"]?["id"]);
    bool isPipeline = type == ToolUseType.pipeline;
    bool isRemoteCall = type == ToolUseType.remoteCall;
    bool isThinking = type == ToolUseType.nativeToolsThinking;
    bool isTodoList = type == ToolUseType.nativeToolsToDoList;
    bool isWebSearch = type == ToolUseType.nativeToolsWebSearch;
    bool isKnowledgeBase = type == ToolUseType.nativeToolsKnowledgeBase;
    bool isDocument = type == ToolUseType.nativeToolsDocument;
    bool isSMTP = type == ToolUseType.nativeToolsSMTP;
    bool isImageGeneration = type == ToolUseType.nativeToolsImageGeneration;
    bool isBrowserUse = type == ToolUseType.nativeToolsBrowserUse;
    bool isAskUser = type == ToolUseType.nativeToolsAskUser;
    bool isWebReader = type == ToolUseType.nativeToolsWebReader;
    Map<String, dynamic> data = ToolUseMessage.getMessage(json, true);

    return ToolUseMessage(
      id: json["id"] ?? "",
      assistantName: json["assistantName"] ?? "",
      imageUuid: json["imageUuid"],
      chatBotId: json["chatBotId"],
      marketPlaceId: json["marketPlaceId"],
      type: type,
      toolName: json["typeDetails"]?["toolName"] ?? "",
      queryGroupId: json["queryGroupId"] ?? "",
      showTool: json["typeDetails"]?["showTool"] ?? true,
      toolMessage: json["typeDetails"]?["toolMessage"] ?? "",
      nativeToolData: ToolUseService.isNativeTool(type)
          ? getNativeToolData(json, true)
          : null,
      pipelineData: isPipeline ? ToolUsePipelineData.fromJson(data) : null,
      remoteCallData: isRemoteCall ? data : null,
      thinkingData: isThinking ? ToolUseThinkingData.fromJson(json["typeDetails"]) : null,
      toDoListData: isTodoList ? ToolUseToDoListData.fromJson(data, json["typeDetails"]) : null,
      webSearchData: isWebSearch ? ToolUseWebSearchData.fromJson(data) : null,
      knowledgeBaseData:
          isKnowledgeBase ? ToolUseKnowledgeBaseData.fromJson(data) : null,
      documentData: isDocument
          ? ToolUseDocumentData.fromJson(data, json["typeDetails"])
          : null,
      smtpData: isSMTP ? ToolUseSMTPData.fromJson(data) : null,
      imageGenerationData:
          isImageGeneration ? ToolUseImageGenerationData.fromJson(data) : null,
      browserUseData: isBrowserUse
          ? ToolUseBrowserUseData.fromJson(data, json["typeDetails"])
          : null,
      askUserData:
          isAskUser ? ToolUseAskUserData.fromJson(json["typeDetails"]) : null,
      webReaderData: isWebReader ? ToolUseWebReaderData.fromJson(data) : null,
    );
  }

  factory ToolUseMessage.fromJson(Map<String, dynamic> json) {
    ToolUseType type = ToolUseService.getToolUseTypeEnum(
        json["extraInfo"]?["typeDetails"]?["toolType"] ?? "",
        nativeToolType: json["extraInfo"]?["typeDetails"]?["nativeTool"]
            ?["id"]);
    bool isPipeline = type == ToolUseType.pipeline;
    bool isRemoteCall = type == ToolUseType.remoteCall;
    bool isThinking = type == ToolUseType.nativeToolsThinking;
    bool isTodoList = type == ToolUseType.nativeToolsToDoList;
    bool isWebSearch = type == ToolUseType.nativeToolsWebSearch;
    bool isKnowledgeBase = type == ToolUseType.nativeToolsKnowledgeBase;
    bool isDocument = type == ToolUseType.nativeToolsDocument;
    bool isSMTP = type == ToolUseType.nativeToolsSMTP;
    bool isImageGeneration = type == ToolUseType.nativeToolsImageGeneration;
    bool isBrowserUse = type == ToolUseType.nativeToolsBrowserUse;
    bool isAskUser = type == ToolUseType.nativeToolsAskUser;
    bool isWebReader = type == ToolUseType.nativeToolsWebReader;
    Map<String, dynamic> answer = getMessage(json, false);

    return ToolUseMessage(
      id: json["id"] ?? "",
      assistantName: json["assistantName"] ?? "",
      imageUuid: json["imageUuid"],
      chatBotId: json["chatBotId"],
      marketPlaceId: json["marketPlaceId"],
      type: type,
      toolName: json["extraInfo"]?["typeDetails"]?["toolName"] ?? "tool",
      queryGroupId: json["queryGroupId"] ?? "",
      showTool: json["extraInfo"]?["typeDetails"]?["showTool"] ?? true,
      toolMessage: json["extraInfo"]?["typeDetails"]?["toolMessage"] ?? "",
      nativeToolData: ToolUseService.isNativeTool(type)
          ? getNativeToolData(json, false)
          : null,
      pipelineData: isPipeline ? ToolUsePipelineData.fromJson(answer) : null,
      remoteCallData: isRemoteCall ? answer : null,
      thinkingData: isThinking ? ToolUseThinkingData.fromJson(json["extraInfo"]?["typeDetails"]) : null,
      toDoListData: isTodoList ? ToolUseToDoListData.fromJson(answer, json["extraInfo"]?["typeDetails"]) : null,
      webSearchData: isWebSearch ? ToolUseWebSearchData.fromJson(answer) : null,
      knowledgeBaseData:
          isKnowledgeBase ? ToolUseKnowledgeBaseData.fromJson(answer) : null,
      documentData: isDocument
          ? ToolUseDocumentData.fromJson(
              answer, json["extraInfo"]?["typeDetails"])
          : null,
      smtpData: isSMTP ? ToolUseSMTPData.fromJson(answer) : null,
      imageGenerationData: isImageGeneration
          ? ToolUseImageGenerationData.fromJson(answer)
          : null,
      browserUseData: isBrowserUse
          ? ToolUseBrowserUseData.fromJson(
              answer, json["extraInfo"]?["typeDetails"])
          : null,
      askUserData: isAskUser
          ? ToolUseAskUserData.fromJson(json["extraInfo"]?["typeDetails"])
          : null,
      webReaderData: isWebReader ? ToolUseWebReaderData.fromJson(answer) : null,
    );
  }

  String getName() {
    if (thinkingData != null && thinkingData!.subject.trim() != "") {
      return thinkingData!.subject;
    }
    if (documentData?.action != null) {
      return toolName.replaceAll("_", " ").capitalize! +
          (" (${documentData!.action!.replaceAll("_", " ").capitalize})");
    }
    if (toDoListData?.action != null) {
      if (toDoListData?.actionParameter != null && toDoListData?.actionParameter != 0 &&
          toDoListData!.tasks.length >= toDoListData!.actionParameter!) {
        return "#${toDoListData!.actionParameter!} ${toDoListData!.tasks[toDoListData!.actionParameter! - 1].task}";
      }
      return "${toolName.replaceAll("_", " ").capitalize!}: (${toDoListData!.action!.replaceAll("_", " ").capitalize})";
    }
    if (webSearchData != null) {
      return "${toolName.replaceAll("_", " ").capitalize!}: (${webSearchData!.type}) ${webSearchData!.query}";
    }
    if (browserUseData != null) {
      return browserUseData!.getBrowserUseActionName();
    }
    if (webReaderData != null) {
      return "${toolName.replaceAll("_", " ").capitalize!}: ${webReaderData!.url}";
    }
    return toolName.replaceAll("_", " ").capitalize ?? toolName;
  }

  static Map<String, dynamic> getMessage(
      Map<String, dynamic> json, bool isSSE) {
    String field = isSSE ? "data" : "answer";
    try {
      if (json[field] != null) {
        String fieldValue = json[field].toString().trim();
        // Check if it's a JSON string (starts with { or [)
        if (fieldValue.startsWith("{") || fieldValue.startsWith("[")) {
          dynamic decoded = jsonDecode(fieldValue);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else {
            return {"message": decoded};
          }
        } else {
          return {"message": json[field]};
        }
      }
    } catch (e) {
      return {};
    }
    return {};
  }

  static Map<String, dynamic> getNativeToolData(
      Map<String, dynamic> json, bool isSse) {
    Map<String, dynamic> message = getMessage(json, isSse);
    Map<String, dynamic> toolArgs = isSse
        ? (json["typeDetails"]?["toolArgs"] ?? {})
        : (json["extraInfo"]?["typeDetails"]?["toolArgs"] ?? {});
    message.addAll(toolArgs);
    message.removeWhere((String key, dynamic value) =>
        value == null ||
        value.toString().trim() == "" ||
        value.toString().trim() == "[]");
    return message;
  }

  static IconData getToolUseSuffixIcon(ToolUseType type) {
    switch (type) {
      case ToolUseType.nativeToolsWebReader:
        return Symbols.call_made;
      default:
        return Symbols.chevron_forward;
    }
  }
}
