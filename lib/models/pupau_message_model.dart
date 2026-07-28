import 'dart:convert';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/models/memory_always_model.dart';
import 'package:flutter_agent_pupau/models/memory_reference_model.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
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
  List<Attachment> attachments =
      <Attachment>[]; //Frontend only - Assigned via api
  List<KbReference> kbReferences;
  List<MemoryReference> memoryReferences;
  List<MemoryAlways> alwaysMemories;
  ContextInfo? contextInfo;

  /// RAG grounding block (`extraInfo.grounding`) — null when the assistant's
  /// `A_GROUNDING_MODE` is OFF (the default), or a live partial version
  /// (IMPLICIT sources only) before the authoritative one lands. See
  /// `GroundingInfo.sourceForMarker`.
  GroundingInfo? grounding;

  /// Raw `groundingSources[]` off the `kb` frame (SSE only, §1.2) — IMPLICIT
  /// sources known live, before the turn closes. Forward-filled onto
  /// [grounding] the same way `kbReferences` is, see
  /// `PupauChatController.handleKbMessage`.
  List<GroundingSource> liveGroundingSources = const [];
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
  AttachmentTrimmingInfo? attachmentTrimming;
  AttachmentTrimmingInfo? emergencyTrimming;
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
  bool? isLast;
  bool? showTool;
  String? toolMessage;
  String? title;

  /// Persisted on assistant query [extraInfo.skillsLoaded] (history).
  List<SkillLoadedInfo> skillsLoaded = const [];

  /// Inline SSE row: compact skill load/unload bubble (not persisted separately).
  SkillEventDetail? skillEventDetail;

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
    this.kbReferences = const [],
    this.memoryReferences = const [],
    this.alwaysMemories = const [],
    this.contextInfo,
    this.grounding,
    this.liveGroundingSources = const [],
    this.urls = const [],
    this.organicInfo = const [],
    this.images = const [],
    this.news = const [],
    this.graphInfo,
    this.relatedSearches = const [],
    this.reaction,
    this.sourceType = SourceType.llm,
    this.attachmentTrimming,
    this.emergencyTrimming,
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
    this.isLast,
    this.showTool,
    this.toolMessage,
    this.title,
    this.attachments = const [],
    this.isAudioInput = false,
    this.transcription,
    this.skillsLoaded = const [],
    this.skillEventDetail,
  });

  bool get isMessageFromAssistant => status != MessageStatus.sent;

  bool get isEmpty =>
      status == MessageStatus.received &&
      answer.trim() == "" &&
      images.isEmpty &&
      news.isEmpty &&
      organicInfo.isEmpty &&
      graphInfo == null &&
      urls.isEmpty &&
      relatedSearches.isEmpty &&
      toolUseAgent == null &&
      toolUseMessage == null &&
      uiToolMessage == null &&
      transcription == null &&
      attachmentTrimming == null &&
      emergencyTrimming == null &&
      skillEventDetail == null &&
      skillsLoaded.isEmpty;

  factory PupauMessage.fromSseStream(Map<String, dynamic> json) {
    try {
      SourceType sourceType = ConversationService.getSourceTypeEnum(
        json["messageType"],
      );
      MessageType? messageType = ConversationService.getMessageTypeEnum(
        json["type"],
      );
      return PupauMessage(
        id: getString(json["id"]),
        groupId: '',
        query: getString(json["query"]),
        answer: sourceType == SourceType.llm ? getString(json["message"]) : "",
        assistantId: getString(json["chatBotId"] ?? json["marketplaceId"]),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        sourceType: sourceType,
        type: messageType,
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
        liveGroundingSources: json["groundingSources"] != null
            ? List<GroundingSource>.from(
                (json["groundingSources"] as List).map(
                  (dynamic x) =>
                      GroundingSource.fromMap(Map<String, dynamic>.from(x)),
                ),
              )
            : const [],
        memoryReferences: json["memoryReferences"] != null
            ? List<MemoryReference>.from(
                json["memoryReferences"].map(
                  (x) => MemoryReference.fromMap(
                    Map<String, dynamic>.from(x as Map),
                  ),
                ),
              )
            : [],
        alwaysMemories: json["alwaysMemories"] != null
            ? List<MemoryAlways>.from(
                json["alwaysMemories"].map(
                  (x) =>
                      MemoryAlways.fromMap(Map<String, dynamic>.from(x as Map)),
                ),
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
        toolName: json["toolName"] ?? json["typeDetails"]?["toolName"],
        toolUseType: json["typeDetails"]?["nativeTool"]?["id"] != null
            ? ToolUseService.getToolUseTypeEnum(
                json["typeDetails"]?["toolType"] ?? "",
                nativeToolType: json["typeDetails"]?["nativeTool"]?["id"],
              )
            : null,
        isLast: getBool(json["last"]),
        showTool: json["typeDetails"]?["showTool"] ?? true,
        toolMessage: json["typeDetails"]?["toolMessage"],
        title: messageType == MessageType.conversationTitleGenerated
            ? getMessageTitle(json)
            : null,
        createdAt: DateTime.now(),
        status: MessageStatus.loading,
        transcription: json["transcription"],
        attachmentTrimming:
            messageType == MessageType.attachmentTrimming &&
                json["data"] != null &&
                json["data"] is Map
            ? AttachmentTrimmingInfo.fromSseData(json["data"])
            : null,
        skillEventDetail: messageType == MessageType.skillLoaded
            ? SkillEventDetail.fromSsePayload(json, isUnload: false)
            : messageType == MessageType.skillUnloaded
            ? SkillEventDetail.fromSsePayload(json, isUnload: true)
            : null,
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
        status: MessageStatus.error,
      );
    }
  }

  /// Resolves the query-group id from a history API payload (REST or SSE).
  static String queryGroupIdFromLoadedJson(Map<String, dynamic> json) {
    final List<String> candidates = <String>[
      getString(json['queryGroupId']),
      getString(json['questionGroupId']),
      getString(json['groupId']),
      getString(json['queryId']),
    ];
    final Object? extraInfo = json['extraInfo'];
    if (extraInfo is Map<String, dynamic>) {
      candidates.add(getString(extraInfo['queryGroupId']));
      candidates.add(getString(extraInfo['queryId']));
    } else if (extraInfo is Map) {
      final Map<dynamic, dynamic> extra = extraInfo;
      candidates.add(getString(extra['queryGroupId']));
      candidates.add(getString(extra['queryId']));
    }
    for (final String candidate in candidates) {
      if (candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  factory PupauMessage.fromLoadedChat(Map<String, dynamic> json) {
    try {
      bool isSkillItem =
          json["extraInfo"]?["typeDetails"]?["toolType"] == "NATIVE_TOOLS" &&
          json["extraInfo"]?["typeDetails"]?["nativeTool"]?["id"] == "SKILL";
      final SkillEventDetail? parsedSkillEventDetail = isSkillItem
          ? SkillEventDetail.fromHistoryNativeToolItem(json)
          : null;
      isSkillItem = parsedSkillEventDetail != null;
      return PupauMessage(
        id: getString(json["id"]),
        answer: isSkillItem ? '' : getString(json["answer"]),
        // REST history uses `query`; SSE history can use `question`.
        query: getString(json["query"] ?? json["question"]),
        assistantId: getString(json["chatBotId"] ?? json["marketplaceId"]),
        assistantType: json["marketplaceId"] != null
            ? AssistantType.marketplace
            : AssistantType.assistant,
        groupId: queryGroupIdFromLoadedJson(json),
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
        grounding: json["extraInfo"]?["grounding"] != null
            ? GroundingInfo.fromMap(
                Map<String, dynamic>.from(json["extraInfo"]["grounding"]),
              ).withQueryId(getString(json["id"]))
            : null,
        attachmentTrimming: AttachmentTrimmingInfo.fromMap(
          json["extraInfo"]?["contextInfo"]?["contextEngineering"]?["attachmentTrimming"] !=
                  null
              ? Map<String, dynamic>.from(
                  json["extraInfo"]["contextInfo"]["contextEngineering"]["attachmentTrimming"],
                )
              : null,
        ),
        emergencyTrimming: AttachmentTrimmingInfo.fromSseDataEmergency(
          json["extraInfo"]?["contextInfo"]?["contextEngineering"]?["emergencyTrimming"] !=
                  null
              ? Map<String, dynamic>.from(
                  json["extraInfo"]["contextInfo"]["contextEngineering"]["emergencyTrimming"],
                )
              : null,
        ),
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
        sourceType: isSkillItem
            ? SourceType.event
            : (json["type"] != null
                  ? ConversationService.getSourceTypeEnum(json["type"])
                  : SourceType.llm),
        type: isSkillItem
            ? (json["extraInfo"]?["typeDetails"]?["toolName"] == 'skill_unload'
                  ? MessageType.skillUnloaded
                  : MessageType.skillLoaded)
            : null,
        toolUseMessage:
            !isSkillItem &&
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
        skillsLoaded: json["extraInfo"]?["skillsLoaded"] != null
            ? List<SkillLoadedInfo>.from(
                (json["extraInfo"]["skillsLoaded"] as List).map(
                  (dynamic x) => SkillLoadedInfo.fromJson(x),
                ),
              )
            : const [],
        skillEventDetail: parsedSkillEventDetail,
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
        groupId: queryGroupIdFromLoadedJson(json),
        createdAt: getDateTime(json["createdAt"] ?? DateTime.now()),
        status: MessageStatus.error,
      );
    }
  }

  static String? getMessageTitle(Map<String, dynamic> json) {
    try {
      if (json["data"] is Map && json["data"]?["title"] != null) {
        return json["data"]?["title"];
      }
      if (json["title"] != null) return json["title"];
      return null;
    } catch (e) {
      return null;
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
    if (messageFromSse.grounding != null) {
      grounding = messageFromSse.grounding;
    }
    if (messageFromSse.attachmentTrimming != null) {
      attachmentTrimming = messageFromSse.attachmentTrimming;
    }
    if (messageFromSse.emergencyTrimming != null) {
      emergencyTrimming = messageFromSse.emergencyTrimming;
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
    if (messageFromSse.kbReferences.isNotEmpty) {
      List<KbReference> newKbReferences = List<KbReference>.from(kbReferences);
      newKbReferences.addAll(messageFromSse.kbReferences);
      kbReferences = newKbReferences;
    }
    if (messageFromSse.memoryReferences.isNotEmpty) {
      List<MemoryReference> newReferences = List<MemoryReference>.from(
        memoryReferences,
      );
      newReferences.addAll(messageFromSse.memoryReferences);
      memoryReferences = newReferences;
    }
    if (messageFromSse.alwaysMemories.isNotEmpty) {
      List<MemoryAlways> newAlways = List<MemoryAlways>.from(alwaysMemories);
      newAlways.addAll(messageFromSse.alwaysMemories);
      alwaysMemories = newAlways;
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
    if (messageFromSse.skillsLoaded.isNotEmpty) {
      skillsLoaded = List<SkillLoadedInfo>.from(messageFromSse.skillsLoaded);
    }
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
    id: getString(json["id"] ?? json["kbId"]),
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

/// Attachment trimming item (per-file detail).
class AttachmentTrimmingItem {
  final String filename;
  final String action; // 'truncated' | 'removed'
  final int estimatedTokensBefore;
  final int estimatedTokensAfter;
  final int estimatedTokensSaved;
  final String reason;

  AttachmentTrimmingItem({
    required this.filename,
    required this.action,
    required this.estimatedTokensBefore,
    required this.estimatedTokensAfter,
    required this.estimatedTokensSaved,
    required this.reason,
  });

  static AttachmentTrimmingItem fromMap(Map<String, dynamic> json) =>
      AttachmentTrimmingItem(
        filename: getString(json["fileName"]),
        action: getString(json["action"]),
        estimatedTokensBefore: getInt(json["estimatedTokensBefore"]),
        estimatedTokensAfter: getInt(json["estimatedTokensAfter"]),
        estimatedTokensSaved: getInt(json["estimatedTokensSaved"]),
        reason: getString(json["reason"]),
      );
}

/// Attachment trimming block (SSE event or persisted contextEngineering.attachmentTrimming).
class AttachmentTrimmingInfo {
  final bool applied;
  final int removedCount;
  final int truncatedCount;
  final List<AttachmentTrimmingItem> items;

  AttachmentTrimmingInfo({
    required this.applied,
    required this.removedCount,
    required this.truncatedCount,
    required this.items,
  });

  /// From persisted contextEngineering.attachmentTrimming.
  static AttachmentTrimmingInfo? fromMap(Map<String, dynamic>? json) {
    if (json == null || !getBool(json["applied"], defaultValue: false)) {
      return null;
    }
    final dynamic itemsList = json["items"];
    final List<AttachmentTrimmingItem> list = itemsList is List
        ? itemsList
              .map(
                (e) => AttachmentTrimmingItem.fromMap(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList()
        : <AttachmentTrimmingItem>[];
    return AttachmentTrimmingInfo(
      applied: true,
      removedCount: getInt(json["removedCount"]),
      truncatedCount: getInt(json["truncatedCount"]),
      items: list,
    );
  }

  /// From SSE ATTACHMENT_TRIMMING event data (summary.truncated/removed, items).
  static AttachmentTrimmingInfo? fromSseDataAttachment(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return null;
    try {
      final Map<String, dynamic> summary = json["summary"] is Map
          ? Map<String, dynamic>.from(json["summary"] as Map)
          : <String, dynamic>{};
      final int truncated = getInt(summary["truncated"]);
      final int removed = getInt(summary["removed"]);
      final dynamic itemsList = json["items"];
      final List<AttachmentTrimmingItem> list = itemsList is List
          ? itemsList
                .map(
                  (e) => AttachmentTrimmingItem.fromMap(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList()
          : <AttachmentTrimmingItem>[];
      final bool hasAttachmentTrimming =
          truncated > 0 || removed > 0 || list.isNotEmpty;
      if (!hasAttachmentTrimming) return null;
      return AttachmentTrimmingInfo(
        applied: true,
        removedCount: removed,
        truncatedCount: truncated,
        items: list,
      );
    } catch (e) {
      return null;
    }
  }

  /// From SSE or loaded chat EMERGENCY_TRIMMING data (summary.message/excessTokens, categoriesAffected).
  static AttachmentTrimmingInfo? fromSseDataEmergency(
    Map<String, dynamic>? json,
  ) {
    if (json == null) return null;
    try {
      final Map<String, dynamic> summary = json["summary"] is Map
          ? Map<String, dynamic>.from(json["summary"] as Map)
          : <String, dynamic>{};
      final dynamic categoriesRaw = json["categoriesAffected"];
      final bool hasEmergencySummary =
          summary["excessTokens"] != null ||
          summary["message"] != null ||
          summary["tokensReduced"] != null;
      final List<dynamic> categoriesList = categoriesRaw is List
          ? categoriesRaw
          : <dynamic>[];
      if (categoriesList.isEmpty && !hasEmergencySummary) return null;
      final String summaryMessage = getString(summary["message"]).trim();
      int totalTokensReduced = 0;
      final List<AttachmentTrimmingItem> emergencyItems = [];
      for (final dynamic c in categoriesList) {
        final Map<String, dynamic> cat = c is Map
            ? Map<String, dynamic>.from(c)
            : <String, dynamic>{};
        final String category = getString(cat["category"]).isEmpty
            ? "context"
            : getString(cat["category"]);
        final int tokensReduced = getInt(cat["tokensReduced"]);
        final double reductionPercent = (cat["reductionPercent"] is num)
            ? (cat["reductionPercent"] as num).toDouble()
            : 0.0;
        totalTokensReduced += tokensReduced;
        final String reason = summaryMessage.isNotEmpty
            ? summaryMessage
            : (reductionPercent > 0
                  ? "$category: ${reductionPercent.toStringAsFixed(1)}% reduced"
                  : category);
        emergencyItems.add(
          AttachmentTrimmingItem(
            filename: category,
            action: 'truncated',
            estimatedTokensBefore: tokensReduced > 0 ? tokensReduced : 0,
            estimatedTokensAfter: 0,
            estimatedTokensSaved: tokensReduced > 0 ? tokensReduced : 0,
            reason: reason,
          ),
        );
      }
      if (totalTokensReduced == 0 && summary["tokensReduced"] != null) {
        totalTokensReduced = getInt(summary["tokensReduced"]).abs();
      }
      if (totalTokensReduced == 0 && emergencyItems.isEmpty) {
        totalTokensReduced = 1;
      }
      return AttachmentTrimmingInfo(
        applied: true,
        removedCount: 0,
        truncatedCount: totalTokensReduced > 0 ? totalTokensReduced : 1,
        items: emergencyItems,
      );
    } catch (e) {
      return null;
    }
  }

  /// From SSE ATTACHMENT_TRIMMING or EMERGENCY_TRIMMING event data.
  /// Tries attachment format first, then emergency. Prefer fromSseDataAttachment/fromSseDataEmergency when event type is known.
  static AttachmentTrimmingInfo? fromSseData(Map<String, dynamic> json) {
    try {
      final AttachmentTrimmingInfo? attachment = fromSseDataAttachment(json);
      if (attachment != null) return attachment;
      return fromSseDataEmergency(json);
    } catch (e) {
      return null;
    }
  }
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
    id: getString(json["id"]),
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
    id: getString(json["id"]),
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
  memory,
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
  toolPending,
  toolArgsDelta,
  toolHeartbeat,
  toolEvaluation,
  toolPartialResult,
  nativeTools,
  noVisionCapability,
  retry,
  conversationTitleGenerated,
  audioInputTranscription,
  attachmentTrimming,
  skillLoaded,
  skillUnloaded,
  heartbeat,
  groundingVerification,
  //message,
  //contextInfo,
  //contextExceeded,
  //brokenAttachments,
  //e2e_issue,
}
