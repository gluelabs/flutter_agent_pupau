import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';

class ToolUseService {
  static ToolUseType getToolUseTypeEnum(String type, {String? nativeToolType}) {
    switch (type) {
      case "REMOTE_CALL":
        return ToolUseType.remoteCall;
      case "PIPELINE":
        return ToolUseType.pipeline;
      case "AGENT":
        return ToolUseType.agent;
      case "MCP_SERVER":
        return ToolUseType.mcpServer;
      case "MCP_SERVER_TOOL":
        return ToolUseType.mcpServerTool;
      case "NATIVE_TOOLS":
        {
          switch (nativeToolType) {
            case "DATABASE":
              return ToolUseType.nativeToolsDatabase;
            case "NATIVE_DATABASE":
              return ToolUseType.nativeToolsNativeDatabase;
            case "WEB_SEARCH":
              return ToolUseType.nativeToolsWebSearch;
            case "TODO_LIST":
              return ToolUseType.nativeToolsToDoList;
            case "PASSTHROUGH":
              return ToolUseType.nativeToolsPassthrough;
            case "SMTP":
              return ToolUseType.nativeToolsSMTP;
            case "MAIL":
              return ToolUseType.nativeToolsMail;
            case "GOOGLE_DRIVE":
              return ToolUseType.nativeToolsGoogleDrive;
            case "RAG":
            case "KNOWLEDGE_BASE":
              return ToolUseType.nativeToolsKnowledgeBase;
            case "DOCUMENT":
              return ToolUseType.nativeToolsDocument;
            case "UI":
              return ToolUseType.nativeToolsUI;
            case "IMAGE_GENERATION":
              return ToolUseType.nativeToolsImageGeneration;
            case "CODE_INTERPRETER":
              return ToolUseType.nativeToolsCodeInterpreter;
            case "WEB_READER":
              return ToolUseType.nativeToolsWebReader;
            case "THINKING":
              return ToolUseType.nativeToolsThinking;
            case "BROWSER_USE":
              return ToolUseType.nativeToolsBrowserUse;
            case "ASK_USER":
              return ToolUseType.nativeToolsAskUser;
            case "CLOSE_CONVERSATION":
              return ToolUseType.nativeToolsCloseConversation;
            case "CREATE_TASK":
              return ToolUseType.nativeToolsTaskTool;
            case "SUBAGENT":
              return ToolUseType.nativeToolsSubagent;
            case "MEMORY_PROFILE":
              return ToolUseType.nativeToolsMemoryProfile;
            case "ATTACHMENT":
              return ToolUseType.nativeToolsAttachment;
            case "SKILL":
              return ToolUseType.nativeToolsSkill;
            case "SHELL":
              return ToolUseType.nativeToolsShell;
            case "ATTACH_ARTIFACT":
              return ToolUseType.nativeToolsAttachArtifact;
            case "IMPORT_ATTACHMENT":
              return ToolUseType.nativeToolsImportAttachment;
            case "IMPORT_TOOL_RESULT":
              return ToolUseType.nativeToolsImportToolResult;
            default:
              return ToolUseType.nativeToolsGeneric;
          }
        }
      default:
        return ToolUseType.defaultTool;
    }
  }

  /// Like [getToolUseTypeEnum], but treats native tool ids (e.g. "DOCUMENT")
  /// as first-class type values (no need for "NATIVE_TOOLS" wrapper).
  ///
  /// This is useful for SSE async events that expose `actorType` directly.
  static ToolUseType getToolUseTypeEnumFlat(String typeOrNativeToolType) {
    switch (typeOrNativeToolType) {
      case "REMOTE_CALL":
        return ToolUseType.remoteCall;
      case "PIPELINE":
        return ToolUseType.pipeline;
      case "AGENT":
        return ToolUseType.agent;
      case "MCP_SERVER":
        return ToolUseType.mcpServer;
      case "MCP_SERVER_TOOL":
        return ToolUseType.mcpServerTool;
      case "DATABASE":
        return ToolUseType.nativeToolsDatabase;
      case "NATIVE_DATABASE":
        return ToolUseType.nativeToolsNativeDatabase;
      case "WEB_SEARCH":
        return ToolUseType.nativeToolsWebSearch;
      case "TODO_LIST":
        return ToolUseType.nativeToolsToDoList;
      case "PASSTHROUGH":
        return ToolUseType.nativeToolsPassthrough;
      case "SMTP":
        return ToolUseType.nativeToolsSMTP;
      case "MAIL":
        return ToolUseType.nativeToolsMail;
      case "GOOGLE_DRIVE":
        return ToolUseType.nativeToolsGoogleDrive;
      case "RAG":
      case "KNOWLEDGE_BASE":
        return ToolUseType.nativeToolsKnowledgeBase;
      case "DOCUMENT":
        return ToolUseType.nativeToolsDocument;
      case "UI":
        return ToolUseType.nativeToolsUI;
      case "IMAGE_GENERATION":
        return ToolUseType.nativeToolsImageGeneration;
      case "CODE_INTERPRETER":
        return ToolUseType.nativeToolsCodeInterpreter;
      case "WEB_READER":
        return ToolUseType.nativeToolsWebReader;
      case "THINKING":
        return ToolUseType.nativeToolsThinking;
      case "BROWSER_USE":
        return ToolUseType.nativeToolsBrowserUse;
      case "ASK_USER":
        return ToolUseType.nativeToolsAskUser;
      case "CLOSE_CONVERSATION":
        return ToolUseType.nativeToolsCloseConversation;
      case "CREATE_TASK":
        return ToolUseType.nativeToolsTaskTool;
      case "SUBAGENT":
        return ToolUseType.nativeToolsSubagent;
      case "MEMORY_PROFILE":
        return ToolUseType.nativeToolsMemoryProfile;
      case "ATTACHMENT":
        return ToolUseType.nativeToolsAttachment;
      case "SKILL":
        return ToolUseType.nativeToolsSkill;
      case "SHELL":
        return ToolUseType.nativeToolsShell;
      case "ATTACH_ARTIFACT":
        return ToolUseType.nativeToolsAttachArtifact;
      case "IMPORT_ATTACHMENT":
        return ToolUseType.nativeToolsImportAttachment;
      case "IMPORT_TOOL_RESULT":
        return ToolUseType.nativeToolsImportToolResult;
      default:
        return ToolUseType.nativeToolsGeneric;
    }
  }

  /// SSE heartbeats and tool names use the `subagent_` prefix (e.g. `subagent_spawn`).
  static bool isSubagentTool(String? toolName) =>
      toolName?.trim().toLowerCase().startsWith('subagent_') ?? false;

  static IconData? getToolUseIcon(ToolUseType? type) {
    if (type == null) return null;
    switch (type) {
      case ToolUseType.remoteCall:
        return Symbols.api;
      case ToolUseType.pipeline:
        return Symbols.valve;
      case ToolUseType.agent:
        return Symbols.support_agent;
      case ToolUseType.mcpServer:
      case ToolUseType.mcpServerTool:
      case ToolUseType.nativeToolsDatabase:
        return Symbols.database;
      case ToolUseType.nativeToolsNativeDatabase:
        return Symbols.dataset_linked;
      case ToolUseType.nativeToolsWebSearch:
        return Symbols.travel_explore;
      case ToolUseType.nativeToolsToDoList:
        return Symbols.checklist;
      case ToolUseType.nativeToolsPassthrough:
        return Symbols.flyover;
      case ToolUseType.nativeToolsSMTP:
        return Symbols.mail;
      case ToolUseType.nativeToolsMail:
        return Symbols.mail;
      case ToolUseType.nativeToolsGoogleDrive:
        return Symbols.drive_file_move;
      case ToolUseType.nativeToolsKnowledgeBase:
        return Symbols.book_2;
      case ToolUseType.nativeToolsDocument:
        return Symbols.file_present;
      case ToolUseType.nativeToolsUI:
        return Symbols.settings;
      case ToolUseType.nativeToolsImageGeneration:
        return Symbols.image;
      case ToolUseType.nativeToolsCodeInterpreter:
        return Symbols.code;
      case ToolUseType.nativeToolsWebReader:
        return Symbols.language;
      case ToolUseType.nativeToolsThinking:
        return Symbols.psychology;
      case ToolUseType.nativeToolsBrowserUse:
        return Symbols.language;
      case ToolUseType.nativeToolsAskUser:
        return Symbols.question_answer;
      case ToolUseType.nativeToolsCloseConversation:
        return Symbols.cancel;
      case ToolUseType.nativeToolsTaskTool:
        return Symbols.alarm;
      case ToolUseType.nativeToolsSubagent:
        return Symbols.graph_2;
      case ToolUseType.nativeToolsMemoryProfile:
        return Symbols.psychology;
      case ToolUseType.nativeToolsAttachment:
        return Symbols.attach_file;
      case ToolUseType.nativeToolsShell:
        return Symbols.terminal;
      case ToolUseType.nativeToolsAttachArtifact:
        return Symbols.attach_file_add;
      case ToolUseType.nativeToolsImportAttachment:
      case ToolUseType.nativeToolsImportToolResult:
        return Symbols.file_download;
      default:
        return Symbols.construction;
    }
  }

  static bool isNativeTool(ToolUseType? type) =>
      type?.name.startsWith('nativeTools') ?? false;

  static ToolParameterType getToolUseParameterTypeEnum(String type) {
    switch (type.toLowerCase()) {
      case "string":
        return ToolParameterType.string;
      case "number":
        return ToolParameterType.number;
      case "boolean":
        return ToolParameterType.boolean;
      case "array":
        return ToolParameterType.array;
      case "object":
        return ToolParameterType.object;
      case "string[]":
        return ToolParameterType.listString;
      case "user:password_credentials":
        return ToolParameterType.passwordCredentials;
      case "google:credentials":
        return ToolParameterType.googleCredentials;
      default:
        return ToolParameterType.string;
    }
  }

  static ToolDocumentAction getToolDocumentActionEnum(String action) {
    switch (action) {
      case "LIST":
        return ToolDocumentAction.list;
      case "CREATE":
        return ToolDocumentAction.create;
      case "GET":
        return ToolDocumentAction.get;
      case "UPDATE":
        return ToolDocumentAction.update;
      case "DELETE":
        return ToolDocumentAction.delete;
      case "INSERT_TEXT":
        return ToolDocumentAction.insertText;
      case "REPLACE_TEXT":
        return ToolDocumentAction.replaceText;
      case "DELETE_TEXT":
        return ToolDocumentAction.deleteText;
      case "EXPORT_PDF":
        return ToolDocumentAction.exportPdf;
      case "EXPORT_DOCX":
        return ToolDocumentAction.exportDocx;
      default:
        return ToolDocumentAction.unknown;
    }
  }

  static String getToolDocumentActionDescription(ToolDocumentAction action) {
    switch (action) {
      case ToolDocumentAction.list:
        return Strings.documentListSuccess.tr;
      case ToolDocumentAction.create:
        return Strings.documentCreateSuccess.tr;
      case ToolDocumentAction.get:
        return Strings.documentGetSuccess.tr;
      case ToolDocumentAction.update:
        return Strings.documentUpdateSuccess.tr;
      case ToolDocumentAction.delete:
        return Strings.documentDeleteSuccess.tr;
      case ToolDocumentAction.insertText:
        return Strings.documentTextInsertSuccess.tr;
      case ToolDocumentAction.replaceText:
        return Strings.documentTextReplaceSuccess.tr;
      case ToolDocumentAction.deleteText:
        return Strings.documentTextDeleteSuccess.tr;
      case ToolDocumentAction.exportPdf:
        return Strings.documentExportPdfSuccess.tr;
      case ToolDocumentAction.exportDocx:
        return Strings.documentExportDocxSuccess.tr;
      case ToolDocumentAction.unknown:
        return Strings.documentOperationFailed.tr;
    }
  }

  static List<DocumentData> setToolUseDocumentsRelatedAttachment(
    List<DocumentData> documents,
  ) {
    List<Attachment> attachments =
        Get.find<PupauAttachmentsController>().getAttachments;
    for (DocumentData document in documents) {
      document.relatedAttachment = attachments.firstWhereOrNull(
        (Attachment attachment) => attachment.id == document.id,
      );
    }
    return documents;
  }

  static List<DocumentData> getToolUseDocumentsWithExportUrl(
    List<DocumentData> documents,
  ) {
    return documents
        .where((DocumentData document) => document.exportUrl != null)
        .toList();
  }

  static bool isInitiallyExpandedTool(ToolUseType? type) =>
      type == ToolUseType.nativeToolsThinking ||
      type == ToolUseType.nativeToolsBrowserUse ||
      type == ToolUseType.nativeToolsAskUser;

  static ToolUseMessage getBrowserLoadingMessage(String name) {
    return ToolUseMessage(
      type: ToolUseType.nativeToolsBrowserUse,
      browserUseData: ToolUseBrowserUseData(
        name: name,
        url: "",
        getDataLayer: false,
        getNetwork: false,
        isLoadingPlaceholder: true,
      ),
      id: '',
      assistantName: '',
      toolName: '',
      queryGroupId: '',
    );
  }

  static bool isModalToolUse(ToolUseType type) {
    switch (type) {
      case ToolUseType.pipeline:
      case ToolUseType.remoteCall:
      case ToolUseType.nativeToolsDatabase:
      case ToolUseType.nativeToolsPassthrough:
      case ToolUseType.nativeToolsGoogleDrive:
        return true;
      default:
        return false;
    }
  }

  static List<DocumentData> resolveDashboardDocuments(
    List<PupauMessage> documentMessages,
  ) {
    final List<DocumentData> result = <DocumentData>[];
    for (final PupauMessage message in documentMessages) {
      final ToolUseMessage? toolUseMessage = message.toolUseMessage;
      if (toolUseMessage?.documentData?.documents == null) continue;
      final List<DocumentData> raw = List<DocumentData>.from(
        toolUseMessage!.documentData!.documents,
      );
      final List<DocumentData> resolved =
          ToolUseService.setToolUseDocumentsRelatedAttachment(raw);
      result.addAll(resolved);
    }
    return result;
  }
}

enum ToolUseType {
  remoteCall,
  pipeline,
  agent,
  mcpServer,
  mcpServerTool,
  nativeToolsGeneric,
  nativeToolsToDoList,
  nativeToolsDatabase,
  nativeToolsNativeDatabase,
  nativeToolsThinking,
  nativeToolsDocument,
  nativeToolsWebSearch,
  nativeToolsWebReader,
  nativeToolsSMTP,
  nativeToolsMail,
  nativeToolsImageGeneration,
  nativeToolsGoogleDrive,
  nativeToolsKnowledgeBase,
  nativeToolsUI,
  nativeToolsCodeInterpreter,
  nativeToolsBrowserUse,
  nativeToolsAskUser,
  nativeToolsCloseConversation,
  nativeToolsPassthrough,
  nativeToolsTaskTool,
  nativeToolsSubagent,
  nativeToolsMemoryProfile,
  nativeToolsAttachment,
  nativeToolsSkill,
  nativeToolsShell,
  nativeToolsAttachArtifact,
  nativeToolsImportAttachment,
  nativeToolsImportToolResult,
  defaultTool,
}

enum ToolDocumentAction {
  list,
  create,
  get,
  update,
  delete,
  insertText,
  replaceText,
  deleteText,
  exportPdf,
  exportDocx,
  unknown,
}

enum ToolParameterType {
  string,
  number,
  boolean,
  array,
  object,
  listString,
  passwordCredentials,
  googleCredentials, //ReadWrite
  googleCredentialsRead, //ReadOnly
}
