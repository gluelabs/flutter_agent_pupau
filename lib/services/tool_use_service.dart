import 'package:flutter/material.dart';
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
            case "WEB_SEARCH":
              return ToolUseType.nativeToolsWebSearch;
            case "TODO_LIST":
              return ToolUseType.nativeToolsToDoList;
            case "PASSTHROUGH":
              return ToolUseType.nativeToolsPassthrough;
            case "SMTP":
              return ToolUseType.nativeToolsSMTP;
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
            default:
              return ToolUseType.nativeToolsGeneric;
          }
        }
      default:
        return ToolUseType.defaultTool;
    }
  }

  static String getToolUseTypeString(
    ToolUseType type, {
    bool getActorId = false,
  }) {
    switch (type) {
      case ToolUseType.remoteCall:
        return "REMOTE_CALL";
      case ToolUseType.pipeline:
        return "PIPELINE";
      case ToolUseType.agent:
        return "AGENT";
      case ToolUseType.mcpServer:
        return "MCP_SERVER";
      case ToolUseType.mcpServerTool:
        return "MCP_SERVER_TOOL";
      case ToolUseType.nativeToolsGeneric:
      case ToolUseType.nativeToolsDatabase:
      case ToolUseType.nativeToolsWebSearch:
      case ToolUseType.nativeToolsToDoList:
      case ToolUseType.nativeToolsPassthrough:
      case ToolUseType.nativeToolsSMTP:
      case ToolUseType.nativeToolsGoogleDrive:
      case ToolUseType.nativeToolsKnowledgeBase:
      case ToolUseType.nativeToolsDocument:
      case ToolUseType.nativeToolsUI:
      case ToolUseType.nativeToolsImageGeneration:
      case ToolUseType.nativeToolsCodeInterpreter:
      case ToolUseType.nativeToolsWebReader:
      case ToolUseType.nativeToolsThinking:
      case ToolUseType.nativeToolsBrowserUse:
      case ToolUseType.nativeToolsAskUser:
      case ToolUseType.nativeToolsCloseConversation:
        if (getActorId) {
          switch (type) {
            case ToolUseType.nativeToolsDatabase:
              return "DATABASE";
            case ToolUseType.nativeToolsWebSearch:
              return "WEB_SEARCH";
            case ToolUseType.nativeToolsToDoList:
              return "TODO_LIST";
            case ToolUseType.nativeToolsPassthrough:
              return "PASSTHROUGH";
            case ToolUseType.nativeToolsSMTP:
              return "SMTP";
            case ToolUseType.nativeToolsGoogleDrive:
              return "GOOGLE_DRIVE";
            case ToolUseType.nativeToolsKnowledgeBase:
              return "KNOWLEDGE_BASE";
            case ToolUseType.nativeToolsDocument:
              return "DOCUMENT";
            case ToolUseType.nativeToolsUI:
              return "UI";
            case ToolUseType.nativeToolsImageGeneration:
              return "IMAGE_GENERATION";
            case ToolUseType.nativeToolsCodeInterpreter:
              return "CODE_INTERPRETER";
            case ToolUseType.nativeToolsWebReader:
              return "WEB_READER";
            case ToolUseType.nativeToolsThinking:
              return "THINKING";
            case ToolUseType.nativeToolsBrowserUse:
              return "BROWSER_USE";
            case ToolUseType.nativeToolsAskUser:
              return "ASK_USER";
            case ToolUseType.nativeToolsCloseConversation:
              return "CLOSE_CONVERSATION";
            default:
              return "NATIVE_TOOLS";
          }
        }
        return "NATIVE_TOOLS";
      default:
        return "DEFAULT";
    }
  }

  static String getApiMethodString(ApiMethod? method) =>
      method?.name.toUpperCase() ?? "GET";

  static ApiMethod getApiMethodEnum(String? method) {
    if (method == null) return ApiMethod.get;
    switch (method) {
      case "GET":
        return ApiMethod.get;
      case "POST":
        return ApiMethod.post;
      case "PUT":
        return ApiMethod.put;
      case "PATCH":
        return ApiMethod.patch;
      case "DELETE":
        return ApiMethod.delete;
      default:
        return ApiMethod.get;
    }
  }

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
      case ToolUseType.nativeToolsWebSearch:
        return Symbols.travel_explore;
      case ToolUseType.nativeToolsToDoList:
        return Symbols.checklist;
      case ToolUseType.nativeToolsPassthrough:
        return Symbols.flyover;
      case ToolUseType.nativeToolsSMTP:
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
      default:
        return Symbols.construction;
    }
  }

  static String getNativeToolUseName(ToolUseType type) {
    switch (type) {
      case ToolUseType.nativeToolsWebSearch:
        return "Web Search";
      case ToolUseType.nativeToolsPassthrough:
        return "Passthrough";
      case ToolUseType.nativeToolsDatabase:
        return "Database";
      case ToolUseType.nativeToolsToDoList:
        return "Todo List";
      case ToolUseType.nativeToolsSMTP:
        return "SMTP";
      case ToolUseType.nativeToolsGoogleDrive:
        return "Google Drive";
      case ToolUseType.nativeToolsKnowledgeBase:
        return "Knowledge Base";
      case ToolUseType.nativeToolsDocument:
        return "Document";
      case ToolUseType.nativeToolsUI:
        return "UI";
      case ToolUseType.nativeToolsImageGeneration:
        return "Image Generation";
      case ToolUseType.nativeToolsCodeInterpreter:
        return "Code Interpreter";
      case ToolUseType.nativeToolsWebReader:
        return "Web Reader";
      case ToolUseType.nativeToolsThinking:
        return "Thinking";
      case ToolUseType.nativeToolsBrowserUse:
        return "Browser Use";
      case ToolUseType.nativeToolsAskUser:
        return "Ask User";
      case ToolUseType.nativeToolsCloseConversation:
        return "Close Conversation";
      default:
        return type.name.capitalize ?? type.name;
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

  static String getToolUseParameterTypeString(ToolParameterType type) {
    switch (type) {
      case ToolParameterType.string:
        return "STRING";
      case ToolParameterType.number:
        return "NUMBER";
      case ToolParameterType.boolean:
        return "BOOLEAN";
      case ToolParameterType.array:
        return "ARRAY";
      case ToolParameterType.object:
        return "OBJECT";
      case ToolParameterType.listString:
        return "STRING[]";
      case ToolParameterType.passwordCredentials:
        return "USER:PASSWORD_CREDENTIALS";
      case ToolParameterType.googleCredentials:
      case ToolParameterType.googleCredentialsRead:
        return "GOOGLE:CREDENTIALS";
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
        Get.find<AttachmentsController>().getAttachments;
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

  static bool isPreviewToolUse(ToolUseType type) =>
      type == ToolUseType.nativeToolsGoogleDrive ||
      type == ToolUseType.nativeToolsKnowledgeBase ||
      type == ToolUseType.nativeToolsUI ||
      type == ToolUseType.nativeToolsCodeInterpreter ||
      type == ToolUseType.nativeToolsBrowserUse ||
      type == ToolUseType.nativeToolsAskUser ||
      type == ToolUseType.nativeToolsCloseConversation ||
      type == ToolUseType.nativeToolsPassthrough;

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
  nativeToolsThinking,
  nativeToolsDocument,
  nativeToolsWebSearch,
  nativeToolsWebReader,
  nativeToolsSMTP,
  nativeToolsImageGeneration,
  nativeToolsGoogleDrive,
  nativeToolsKnowledgeBase,
  nativeToolsUI,
  nativeToolsCodeInterpreter,
  nativeToolsBrowserUse,
  nativeToolsAskUser,
  nativeToolsCloseConversation,
  nativeToolsPassthrough,
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

enum ApiMethod { get, post, put, patch, delete }
