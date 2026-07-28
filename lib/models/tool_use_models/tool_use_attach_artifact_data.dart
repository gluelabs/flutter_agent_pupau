import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Result of the `attach_artifact` native tool (nativeTool.id ==
/// "ATTACH_ARTIFACT"): shares a file from the assistant's sandbox VM to the
/// chat as a real conversation attachment (`attachmentId` in the response
/// refers to that new attachment).
class ToolUseAttachArtifactData {
  final String path;
  final String filename;

  final bool success;
  final String fileName;
  final int sizeBytes;
  final String attachmentId;
  final String workspaceId;

  ToolUseAttachArtifactData({
    required this.path,
    required this.filename,
    required this.success,
    required this.fileName,
    required this.sizeBytes,
    required this.attachmentId,
    required this.workspaceId,
  });

  factory ToolUseAttachArtifactData.fromJson(
    Map<String, dynamic> message,
    Map<String, dynamic>? typeDetails,
  ) {
    final Map<String, dynamic>? toolArgs = typeDetails?['toolArgs'] is Map
        ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map)
        : null;

    final Map<String, dynamic> response = _extractBestResponse(message);

    return ToolUseAttachArtifactData(
      path: getString(toolArgs?['path']),
      filename: getString(toolArgs?['filename']),
      success: getBool(response['success']),
      fileName: getString(response['fileName']),
      sizeBytes: getInt(response['sizeBytes']),
      attachmentId: getString(response['attachmentId']),
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
