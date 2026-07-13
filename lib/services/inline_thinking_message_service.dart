import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_thinking_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

/// Builds synthetic [ToolUseType.nativeToolsThinking] rows for inline `<thinking>`
/// extracted from LLM answers (SSE and history). Consecutive `<thinking>` blocks
/// are merged into one row per run ([TagService.groupedConsecutiveThinkingTagSegments]).
class InlineThinkingMessageService {
  InlineThinkingMessageService._();

  static const String idSuffix = '_thinking';
  static final RegExp _indexedIdSuffixRegex = RegExp(r'_thinking_\d+$');

  /// Stable id for an inline-thinking sibling: `{parentLlmMessageId}_thinking_{blockIndex}`.
  ///
  /// [blockIndex] is 1-based (first `<thinking>` block → `1`).
  static String messageIdFor({
    required String parentLlmMessageId,
    required int blockIndex,
  }) => '${parentLlmMessageId.trim()}${idSuffix}_$blockIndex';

  /// Whether [messageId] is a synthetic inline-thinking row.
  static bool isInlineThinkingMessage(String messageId) {
    final String trimmedId = messageId.trim();
    return _indexedIdSuffixRegex.hasMatch(trimmedId) ||
        trimmedId.endsWith(idSuffix);
  }

  /// Parsed parent LLM id and block index from a thinking sibling id.
  static ({String parentLlmMessageId, int blockIndex})?
  parseInlineThinkingMessageId(String thinkingMessageId) {
    final String trimmedId = thinkingMessageId.trim();
    final RegExpMatch? indexedMatch = RegExp(
      r'^(.+)_thinking_(\d+)$',
    ).firstMatch(trimmedId);
    if (indexedMatch != null) {
      final String? indexText = indexedMatch.group(2);
      final int? blockIndex = indexText == null
          ? null
          : int.tryParse(indexText);
      if (blockIndex != null && blockIndex > 0) {
        return (
          parentLlmMessageId: indexedMatch.group(1) ?? '',
          blockIndex: blockIndex,
        );
      }
    }
    if (trimmedId.endsWith(idSuffix) &&
        !_indexedIdSuffixRegex.hasMatch(trimmedId)) {
      return (
        parentLlmMessageId: trimmedId.substring(
          0,
          trimmedId.length - idSuffix.length,
        ),
        blockIndex: 1,
      );
    }
    return null;
  }

  /// Parent LLM id from a thinking sibling id, or `null` if not an inline-thinking id.
  static String? parentLlmMessageIdFromThinkingId(String thinkingMessageId) {
    return parseInlineThinkingMessageId(thinkingMessageId)?.parentLlmMessageId;
  }

  /// Maps the parent LLM status to a tool-use row status (keeps [MessageStatus.loading] while streaming).
  static MessageStatus normalizeAssistantStatus(MessageStatus parentStatus) {
    if (parentStatus == MessageStatus.loading) return MessageStatus.loading;
    return MessageStatus.received;
  }

  /// Query-group id shared by the user query, LLM answer, tool rows, and inline thinking.
  static String queryGroupIdFor(PupauMessage parentLlmMessage) {
    final String fromGroupId = parentLlmMessage.groupId;
    if (fromGroupId.isNotEmpty) return fromGroupId;
    final String fromToolUse =
        parentLlmMessage.toolUseMessage?.queryGroupId.trim() ?? '';
    if (fromToolUse.isNotEmpty) return fromToolUse;
    return parentLlmMessage.id.trim();
  }

  /// Builds a [ToolUseType.nativeToolsThinking] payload for the synthetic sibling row.
  static ToolUseMessage buildToolUseMessage({
    required String thinkingMessageId,
    required String parentLlmMessageId,
    required String queryGroupId,
    required ToolUseThinkingData thinkingData,
  }) {
    return ToolUseMessage(
      id: thinkingMessageId,
      messageId: parentLlmMessageId,
      assistantName: "",
      type: ToolUseType.nativeToolsThinking,
      toolName: "thinking",
      queryGroupId: queryGroupId,
      toolMessage: thinkingData.subject,
      thinkingData: thinkingData,
    );
  }

  /// Creates the [PupauMessage] sibling for one `<thinking>` block.
  static PupauMessage buildSiblingMessage({
    required PupauMessage parentLlmMessage,
    required int blockIndex,
    required String rawThinkingSegment,
    required ToolUseThinkingData thinkingData,
  }) {
    final String queryGroupId = queryGroupIdFor(parentLlmMessage);
    final String thinkingId = messageIdFor(
      parentLlmMessageId: parentLlmMessage.id,
      blockIndex: blockIndex,
    );
    return PupauMessage(
      id: thinkingId,
      answer: rawThinkingSegment,
      assistantId: parentLlmMessage.assistantId,
      assistantType: parentLlmMessage.assistantType,
      groupId: queryGroupId,
      createdAt: parentLlmMessage.createdAt,
      status: normalizeAssistantStatus(parentLlmMessage.status),
      sourceType: SourceType.toolUse,
      toolUseMessage: buildToolUseMessage(
        thinkingMessageId: thinkingId,
        parentLlmMessageId: parentLlmMessage.id,
        queryGroupId: queryGroupId,
        thinkingData: thinkingData,
      ),
    );
  }
}
