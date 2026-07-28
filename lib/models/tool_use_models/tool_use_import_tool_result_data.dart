import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Result of the `import_tool_result` native tool (nativeTool.id ==
/// "IMPORT_TOOL_RESULT"): imports a previous large tool result (referenced
/// by `handle`) into the assistant's sandbox VM workspace as a file, at the
/// requested path — so a later tool (code interpreter, shell, ...) can
/// process it directly instead of it living only in the conversation.
class ToolUseImportToolResultData {
  final String sourceHandle;
  final String requestedPath;

  final bool success;
  final String handle;
  final int sizeBytes;
  final String path;
  final String workspaceId;

  ToolUseImportToolResultData({
    required this.sourceHandle,
    required this.requestedPath,
    required this.success,
    required this.handle,
    required this.sizeBytes,
    required this.path,
    required this.workspaceId,
  });

  factory ToolUseImportToolResultData.fromJson(
    Map<String, dynamic> message,
    Map<String, dynamic>? typeDetails,
  ) {
    final Map<String, dynamic>? toolArgs = typeDetails?['toolArgs'] is Map
        ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map)
        : null;

    final Map<String, dynamic> response = _extractBestResponse(message);

    return ToolUseImportToolResultData(
      sourceHandle: getString(toolArgs?['handle']),
      requestedPath: getString(toolArgs?['path']),
      success: getBool(response['success']),
      handle: getString(response['handle']),
      sizeBytes: getInt(response['sizeBytes']),
      path: getString(response['path']),
      workspaceId: getString(response['workspaceId']),
    );
  }

  static Map<String, dynamic> _extractBestResponse(
    Map<String, dynamic> message,
  ) {
    final dynamic info = message['info'];
    if (info is List && info.isNotEmpty) {
      final dynamic first = info.first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }

    final Map<String, dynamic>? decoded = _decodeJsonObject(message['message']);
    if (decoded != null) return decoded;

    return message;
  }

  static Map<String, dynamic>? _decodeJsonObject(dynamic value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('{')) return null;
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
