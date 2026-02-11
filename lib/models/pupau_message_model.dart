import 'dart:convert';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

List<PupauMessage> messagesFromLoadedChat(String str) =>
    List<PupauMessage>.from(
      json.decode(str).map((x) => PupauMessage.fromLoadedChat(x)),
    );

class PupauMessage {
  String id;
  String groupId;
  String query;
  String answer;
  String assistantId;
  AssistantType assistantType;
  MessageType? type;
  DateTime createdAt;
  MessageStatus status;
  bool isInitialMessage = false;
  List<Attachment> attachments =
      <Attachment>[]; //Frontend only - Assigned via api
  List<KbReference> kbReferences;
  ContextInfo? contextInfo;
  List<UrlInfo> urls = [];
  List<OrganicInfo> organicInfo = [];
  List<WebSearchImage> images = [];
  List<WebSearchNews> news = [];
  GraphInfo? graphInfo;
  List<String> relatedSearches = [];
  Reaction? reaction = Reaction.none;
  ToolUseAgent? toolUseAgent;
  bool webBased = false;
  SourceType sourceType;
  ToolUseMessage? toolUseMessage;
  UiToolMessage? uiToolMessage;
  bool isExternalSearch = false;
  bool isCancelled = false;
  bool isNarrating = false;
  bool isAudioInput = false;
  String? transcription;
  // SSE Stream only
  String? error;
  int? code;
  String? forbidden;
  String? websearchQuery;
  WebSearchType? webSearchType;
  String? toolName;
  ToolUseType? toolUseType;
  bool? isBrowserTool;
  bool? isLast;
  bool? showTool;
  String? toolMessage;
  String? title;

  PupauMessage({
    required this.id,
    required this.answer,
    required this.assistantId,
    required this.assistantType,
    this.groupId = '',
    this.query = '',
    required this.createdAt,
    required this.status,
    this.type,
    this.isInitialMessage = false,
    this.kbReferences = const [],
    this.contextInfo,
    this.urls = const [],
    this.organicInfo = const [],
    this.images = const [],
    this.news = const [],
    this.graphInfo,
    this.relatedSearches = const [],
    this.reaction,
    this.sourceType = SourceType.llm,
    this.toolUseAgent,
    this.toolUseMessage,
    this.uiToolMessage,
    this.webBased = false,
    this.isExternalSearch = false,
    this.isCancelled = false,
    this.isNarrating = false,
    this.error,
    this.code,
    this.forbidden,
    this.websearchQuery,
    this.webSearchType,
    this.toolName,
    this.toolUseType,
    this.isBrowserTool,
    this.isLast,
    this.showTool,
    this.toolMessage,
    this.title,
    this.attachments = const [],
    this.isAudioInput = false,
    this.transcription,
  });

  bool get isMessageFromAssistant => status != MessageStatus.sent;

  factory PupauMessage.fromSseStream(Map<String, dynamic> json) {
    try {
      return PupauMessage(
        id: json["id"] ?? "",
        groupId: '',
        query: getString(json["query"]),
        answer: getString(json["message"]),
        assistantId: getString(json["chatBotId"] ?? json["marketplaceId"]),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        sourceType: ConversationService.getSourceTypeEnum(json["messageType"]),
        type: ConversationService.getMessageTypeEnum(json["type"]),
        error: json["error"] == null
            ? null
            : json["error"] is String
            ? json["error"]
            : json["error"]?["message"] ?? json["error"]?["statusText"],
        code: json["code"],
        forbidden: json["forbidden"],
        kbReferences: json["kbReferences"] != null
            ? List<KbReference>.from(
                json["kbReferences"].map((x) => KbReference.fromMap(x)),
              )
            : [],
        urls: json["urls"].runtimeType != Null
            ? List<UrlInfo>.from(json["urls"].map((x) => UrlInfo.fromMap(x)))
            : [],
        organicInfo: json["info"]?["organic"] != null
            ? List<OrganicInfo>.from(
                json["info"]["organic"].map((x) => OrganicInfo.fromMap(x)),
              )
            : [],
        images: json["info"]?["images"] != null
            ? List<WebSearchImage>.from(
                json["info"]["images"].map((x) => WebSearchImage.fromMap(x)),
              )
            : [],
        news: json["info"]?["news"] != null
            ? List<WebSearchNews>.from(
                json["info"]["news"].map((x) => WebSearchNews.fromMap(x)),
              )
            : [],
        websearchQuery: json["query"],
        webSearchType: ConversationService.getWebSearchTypeEnum(
          json["searchType"],
        ),
        contextInfo: json["info"] != null
            ? ContextInfo.fromMap(json["info"] ?? {})
            : null,
        graphInfo: json["info"]?["graph"] != null
            ? GraphInfo.fromMap(json["info"]["graph"])
            : null,
        relatedSearches: json["info"]?["relatedSearches"] != null
            ? List<String>.from(
                (json["info"]["relatedSearches"] as List)
                    .where((x) => x != null)
                    .map((x) => x?["query"] ?? ""),
              )
            : [],
        toolUseAgent: json["typeDetails"]?["agent"] != null
            ? ToolUseAgent.fromMap(json["typeDetails"]?["agent"])
            : null,
        toolName: json["typeDetails"]?["toolName"],
        toolUseType: json["typeDetails"]?["nativeTool"]?["id"] != null
            ? ToolUseService.getToolUseTypeEnum(
                json["typeDetails"]?["toolType"] ?? "",
                nativeToolType: json["typeDetails"]?["nativeTool"]?["id"],
              )
            : null,
        isBrowserTool:
            json["typeDetails"]?["nativeTool"]?["id"] == "BROWSER_USE",
        isLast: getBool(json["last"]),
        showTool: json["typeDetails"]?["showTool"] ?? true,
        toolMessage: json["typeDetails"]?["toolMessage"],
        title: json["title"],
        createdAt: DateTime.now(),
        status: MessageStatus.loading,
        transcription: json["transcription"]
      );
    } catch (e) {
      return PupauMessage(
        id: getString(json["id"]),
        answer: getString(json["answer"]),
        query: getString(json["query"]),
        assistantId: getString(json["chatBotId"] ?? json["marketplaceId"]),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        createdAt: DateTime.now(),
        status: MessageStatus.loading,
      );
    }
  }

  factory PupauMessage.fromLoadedChat(Map<String, dynamic> json) {
    try {
      return PupauMessage(
        id: getString(json["id"]),
        answer: getString(json["answer"]),
        query: getString(json["query"]),
        assistantId: getString(json["chatBotId"] ?? json["marketplaceId"]),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        groupId: getString(json["queryGroupId"]),
        status: MessageStatus.loading,
        createdAt: getDateTime(json["createdAt"]),
        kbReferences: json["extraInfo"]?["kbReferences"] != null
            ? List<KbReference>.from(
                json["extraInfo"]["kbReferences"].map(
                  (x) => KbReference.fromMap(x),
                ),
              )
            : [],
        contextInfo: json["extraInfo"]?["contextInfo"] != null
            ? ContextInfo.fromMap(json["extraInfo"]["contextInfo"])
            : null,
        organicInfo:
            json["extraInfo"]?["webSearchLinksInfo"]?["organic"] != null
            ? List<OrganicInfo>.from(
                json["extraInfo"]["webSearchLinksInfo"]["organic"].map(
                  (x) => OrganicInfo.fromMap(x),
                ),
              )
            : [],
        images: json["extraInfo"]?["webSearchLinksInfo"]?["images"] != null
            ? List<WebSearchImage>.from(
                json["extraInfo"]["webSearchLinksInfo"]["images"].map(
                  (x) => WebSearchImage.fromMap(x),
                ),
              )
            : [],
        news: json["extraInfo"]?["webSearchLinksInfo"]?["news"] != null
            ? List<WebSearchNews>.from(
                json["extraInfo"]["webSearchLinksInfo"]["news"].map(
                  (x) => WebSearchNews.fromMap(x),
                ),
              )
            : [],
        graphInfo: json["extraInfo"]?["webSearchLinksInfo"]?["graph"] != null
            ? GraphInfo.fromMap(
                json["extraInfo"]["webSearchLinksInfo"]["graph"],
              )
            : null,
        relatedSearches:
            json["extraInfo"]?["webSearchLinksInfo"]?["relatedSearches"] != null
            ? List<String>.from(
                json["extraInfo"]["webSearchLinksInfo"]["relatedSearches"].map(
                  (x) => x["query"] ?? "",
                ),
              )
            : [],
        reaction: ConversationService.getReactionEnum(json["reaction"] ?? ""),
        webBased: getBool(json["webBased"]),
        sourceType: json["type"] != null
            ? ConversationService.getSourceTypeEnum(json["type"])
            : SourceType.llm,
        toolUseMessage:
            ConversationService.getSourceTypeEnum(json["type"]) ==
                SourceType.toolUse
            ? ToolUseMessage.fromJson(json)
            : null,
        uiToolMessage:
            ConversationService.getSourceTypeEnum(json["type"]) ==
                SourceType.uiTool
            ? UiToolMessage.fromJson(json)
            : null,
        isAudioInput: json["extraInfo"]?["inputType"] == "audio",
      );
    } catch (e) {
      return PupauMessage(
        id: getString(json["id"] ?? ""),
        answer: getString(json["answer"] ?? ""),
        query: getString(json["query"] ?? ""),
        assistantId: getString(json["chatBotId"] ?? ""),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        groupId: getString(json["queryGroupId"] ?? ""),
        createdAt: getDateTime(json["createdAt"] ?? DateTime.now()),
        status: MessageStatus.error,
      );
    }
  }

  /// Merges the current SSE message with a new SSE message.
  /// This method updates the current message with data from the new message,
  /// concatenating the message text and updating other fields as needed.
  void mergeWith(PupauMessage messageFromSse) {
    answer += messageFromSse.answer;
    if (messageFromSse.contextInfo != null) {
      contextInfo = messageFromSse.contextInfo;
    }
    if (messageFromSse.organicInfo.isNotEmpty) {
      organicInfo = messageFromSse.organicInfo;
    }
    if (messageFromSse.images.isNotEmpty) {
      images = messageFromSse.images;
    }
    if (messageFromSse.news.isNotEmpty) {
      news = messageFromSse.news;
    }
    if (messageFromSse.graphInfo != null) {
      graphInfo = messageFromSse.graphInfo;
    }
    if (messageFromSse.relatedSearches.isNotEmpty) {
      relatedSearches = messageFromSse.relatedSearches;
    }
    if (messageFromSse.toolUseAgent != null) {
      toolUseAgent = messageFromSse.toolUseAgent;
    }
    if (messageFromSse.toolUseMessage != null) {
      toolUseMessage = messageFromSse.toolUseMessage;
    }
    if (messageFromSse.uiToolMessage != null) {
      uiToolMessage = messageFromSse.uiToolMessage;
    }
    if (messageFromSse.isBrowserTool == true) {
      isBrowserTool = messageFromSse.isBrowserTool;
    }
    if (messageFromSse.kbReferences.isNotEmpty) {
      List<KbReference> newKbReferences = List<KbReference>.from(kbReferences);
      newKbReferences.addAll(messageFromSse.kbReferences);
      kbReferences = newKbReferences;
    }
    if (messageFromSse.forbidden != null) {
      forbidden = messageFromSse.forbidden;
    }
    if (messageFromSse.websearchQuery != null) {
      websearchQuery = messageFromSse.websearchQuery;
    }
    if (messageFromSse.webSearchType != null) {
      webSearchType = messageFromSse.webSearchType;
    }
    if (messageFromSse.toolName != null) {
      toolName = messageFromSse.toolName;
    }
    sourceType = messageFromSse.sourceType;
    isLast = messageFromSse.isLast;
  }
}

class KbReference {
  String? id;
  String type;
  String data;
  String? pageNumber;

  KbReference({
    required this.id,
    required this.type,
    required this.data,
    this.pageNumber,
  });

  factory KbReference.fromMap(Map<String, dynamic> json) => KbReference(
    id: json["id"] ?? json["kbId"],
    type: json["type"] ?? "",
    data: json["data"] ?? "",
    pageNumber: json["pageNumber"],
  );
}

class ContextInfo {
  double credit;
  int availableContext;
  int usedContext;
  int outputTokens;
  int userQuery;

  ContextInfo({
    required this.credit,
    required this.availableContext,
    required this.usedContext,
    required this.outputTokens,
    required this.userQuery,
  });

  factory ContextInfo.fromMap(Map<String, dynamic> json) => ContextInfo(
    credit: getDouble(json["credit"]),
    availableContext: getInt(json["availableContext"]),
    usedContext: getInt(json["usedContext"]),
    outputTokens: getInt(json["outputTokens"]),
    userQuery: getInt(json["userQuery"]),
  );
}

class OrganicInfo {
  String title;
  String link;
  String snippet;
  String date;

  OrganicInfo({
    required this.title,
    required this.link,
    required this.snippet,
    required this.date,
  });

  factory OrganicInfo.fromMap(Map<String, dynamic> json) => OrganicInfo(
    title: json["title"] ?? "",
    link: json["link"] ?? "",
    snippet: json["snippet"] ?? "",
    date: json["date"] ?? "",
  );
}

class WebSearchImage {
  String title;
  String imageUrl;

  WebSearchImage({required this.title, required this.imageUrl});

  factory WebSearchImage.fromMap(Map<String, dynamic> json) => WebSearchImage(
    title: json["title"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
  );
}

class WebSearchNews {
  String title;
  String link;
  String snippet;
  String date;
  String source;
  String imageUrl;

  WebSearchNews({
    required this.title,
    required this.link,
    required this.snippet,
    required this.date,
    required this.source,
    required this.imageUrl,
  });

  factory WebSearchNews.fromMap(Map<String, dynamic> json) => WebSearchNews(
    title: json["title"] ?? "",
    link: json["link"] ?? "",
    snippet: json["snippet"] ?? "",
    date: json["date"] ?? "",
    source: json["source"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
  );
}

class GraphInfo {
  String title;
  String imageUrl;
  String description;
  String descriptionSource;
  String descriptionLink;
  List<Map<String, String>> attributes;

  GraphInfo({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.descriptionSource,
    required this.descriptionLink,
    required this.attributes,
  });

  factory GraphInfo.fromMap(Map<String, dynamic> json) => GraphInfo(
    title: json["title"] ?? "",
    imageUrl: json["imageUrl"] ?? "",
    description: json["description"] ?? "",
    descriptionSource: json["descriptionSource"] ?? "",
    descriptionLink: json["descriptionLink"] ?? "",
    attributes:
        (json["attributes"] as Map<String, dynamic>?)?.entries
            .map((e) => {e.key: e.value.toString()})
            .toList() ??
        [],
  );
}

class UrlInfo {
  String url;
  bool success;
  AttachmentInfo? attachment;

  UrlInfo({required this.url, required this.success, this.attachment});

  factory UrlInfo.fromMap(Map<String, dynamic> json) => UrlInfo(
    url: json["url"] ?? "",
    success: json["success"] ?? false,
    attachment: json["attachment"].runtimeType != Null
        ? AttachmentInfo.fromMap(json["attachment"])
        : null,
  );
}

class AttachmentInfo {
  String id;
  AttachmentType type;

  AttachmentInfo({required this.id, required this.type});

  factory AttachmentInfo.fromMap(Map<String, dynamic> json) => AttachmentInfo(
    id: json["id"] ?? "",
    type: ConversationService.getAttachmentTypeEnum(json["type"] ?? ""),
  );
}

class ToolUseAgent {
  String id;
  String name;
  String imageUuid;
  AssistantType type;

  ToolUseAgent({
    required this.id,
    required this.name,
    required this.imageUuid,
    required this.type,
  });

  factory ToolUseAgent.fromMap(Map<String, dynamic> json) => ToolUseAgent(
    id: json["id"] ?? "",
    name: json["name"] ?? "",
    imageUuid: json["imageUuid"] ?? "",
    type: AssistantService.getAssistantTypeEnum(json["type"] ?? ""),
  );
}

enum MessageStatus { sent, loading, received, error }

enum Reaction { none, like, dislike }

enum AttachmentType { webpageText, webpageCode }

enum WebSearchType { webSearch, imageSearch, newsSearch }

enum SourceType { llm, toolUse, uiTool, event }

enum MessageType {
  kb,
  error,
  forbidden,
  noDocument,
  webBased,
  webSearch,
  webSearchQuery,
  webSearchInfo,
  layerMessage,
  layerResponse,
  toolUseStart,
  noVisionCapability,
  retry,
  conversationTitleGenerated,
  audioInputTranscription,
  //message,
  //contextInfo,
  //contextExceeded,
  //brokenAttachments,
  //e2e_issue,
}
