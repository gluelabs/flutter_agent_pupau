import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Result of the `shell` native tool (nativeTool.id == "SHELL"): runs a
/// bash command inside the assistant's sandbox VM.
class ToolUseShellData {
  final String command;
  final int timeoutMs;

  final bool success;
  final String stdout;
  final String stderr;
  final int exitCode;
  final int executionTimeMs;
  final String workspaceId;

  ToolUseShellData({
    required this.command,
    required this.timeoutMs,
    required this.success,
    required this.stdout,
    required this.stderr,
    required this.exitCode,
    required this.executionTimeMs,
    required this.workspaceId,
  });

  factory ToolUseShellData.fromJson(
    Map<String, dynamic> message,
    Map<String, dynamic>? typeDetails,
  ) {
    final Map<String, dynamic>? toolArgs = typeDetails?['toolArgs'] is Map
        ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map)
        : null;

    final Map<String, dynamic> response = _extractBestResponse(message);

    return ToolUseShellData(
      command: getString(toolArgs?['command']),
      timeoutMs: getInt(toolArgs?['timeoutMs']),
      success: getBool(response['success']),
      stdout: getString(response['stdout']),
      stderr: getString(response['stderr']),
      exitCode: getInt(response['exitCode']),
      executionTimeMs: getInt(response['executionTime']),
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
