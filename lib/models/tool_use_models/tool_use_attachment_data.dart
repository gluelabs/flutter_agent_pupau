import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Reference to a source attachment returned in `data.info[]`
/// (`{ id: sqid, fileName }`) by any of the JIT attachment tools.
class ToolUseAttachmentInfoItem {
  final String id;
  final String fileName;

  ToolUseAttachmentInfoItem({required this.id, required this.fileName});

  factory ToolUseAttachmentInfoItem.fromJson(Map<String, dynamic> json) =>
      ToolUseAttachmentInfoItem(
        id: getString(json['id']),
        fileName: getString(json['fileName']),
      );
}

/// Result of one of the 5 JIT attachment tools:
/// list_attachments / attachment_outline / attachment_read / attachment_grep
/// / attachment_search.
///
/// Every one of them shares the same result envelope on the wire:
/// `{ message: string, info: [{id, fileName}] }`, optionally truncated with
/// a literal `...(truncated from N chars)...` suffix on `message` (plain
/// text, not JSON, so no `_truncated` marker is used here).
class ToolUseAttachmentData {
  static final RegExp _truncationSuffix = RegExp(
    r'\.\.\.\(truncated from (\d+) chars\)\.\.\.\s*$',
  );

  final String toolName;
  final Map<String, dynamic> toolArgs;
  final bool success;

  /// `data.message` with the truncation suffix (if any) stripped off.
  final String displayMessage;
  final bool isTruncated;
  final int? truncatedFromChars;

  final List<ToolUseAttachmentInfoItem> info;

  ToolUseAttachmentData({
    required this.toolName,
    required this.toolArgs,
    required this.success,
    required this.displayMessage,
    required this.isTruncated,
    required this.truncatedFromChars,
    required this.info,
  });

  factory ToolUseAttachmentData.fromToolUseMessage({
    required String toolName,
    required Map<String, dynamic> rawJson,
    required Map<String, dynamic> message,
    required Map<String, dynamic>? typeDetails,
  }) {
    final Map<String, dynamic> toolArgs = typeDetails?['toolArgs'] is Map
        ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map)
        : const {};

    // `toolSuccess` isn't guaranteed to live in one fixed spot across SSE
    // and history payloads, so check the plausible locations defensively.
    final dynamic successValue =
        rawJson['toolSuccess'] ??
        typeDetails?['toolSuccess'] ??
        rawJson['extraInfo']?['toolSuccess'];
    final bool success = getBool(successValue, defaultValue: true);

    final String finalMessage = getString(message['message']);

    final RegExpMatch? truncationMatch = _truncationSuffix.firstMatch(
      finalMessage,
    );
    final bool isTruncated = truncationMatch != null;
    final int? truncatedFromChars = truncationMatch != null
        ? int.tryParse(truncationMatch.group(1) ?? '')
        : null;
    final String displayMessage = isTruncated
        ? finalMessage.substring(0, truncationMatch.start).trimRight()
        : finalMessage;

    final List<dynamic> infoRaw = message['info'] is List
        ? message['info'] as List
        : const [];
    final List<ToolUseAttachmentInfoItem> info = infoRaw
        .whereType<Map>()
        .map(
          (dynamic e) => ToolUseAttachmentInfoItem.fromJson(
            Map<String, dynamic>.from(e),
          ),
        )
        .toList();

    return ToolUseAttachmentData(
      toolName: toolName,
      toolArgs: toolArgs,
      success: success,
      displayMessage: displayMessage,
      isTruncated: isTruncated,
      truncatedFromChars: truncatedFromChars,
      info: info,
    );
  }
}
