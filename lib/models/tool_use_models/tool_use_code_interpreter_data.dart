import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class ToolUseCodeInterpreterData {
  final String language;
  final String code;
  final int timeoutMs;

  final bool success;
  final String output;
  final List<String> errors;
  final String sandboxId;
  final bool sandboxCreated;
  final bool resumeFailed;
  final int executionTimeMs;

  final int tokensUsed;
  final double creditsUsed;

  ToolUseCodeInterpreterData({
    required this.language,
    required this.code,
    required this.timeoutMs,
    required this.success,
    required this.output,
    required this.errors,
    required this.sandboxId,
    required this.sandboxCreated,
    required this.resumeFailed,
    required this.executionTimeMs,
    required this.tokensUsed,
    required this.creditsUsed,
  });

  factory ToolUseCodeInterpreterData.fromJson(
    Map<String, dynamic> message,
    Map<String, dynamic>? typeDetails,
  ) {
    final Map<String, dynamic>? toolArgs =
        typeDetails?['toolArgs'] is Map
            ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map)
            : null;

    final String language = getString(toolArgs?['language']);
    final String code = getString(toolArgs?['code']);
    final int timeoutMs = getInt(toolArgs?['timeoutMs']);

    final Map<String, dynamic> response = _extractBestResponse(message);
    final Map<String, dynamic>? metadata = response['metadata'] is Map
        ? Map<String, dynamic>.from(response['metadata'] as Map)
        : null;

    final List<String> errors = _stringList(response['errors']);

    return ToolUseCodeInterpreterData(
      language: language,
      code: code,
      timeoutMs: timeoutMs,
      success: getBool(response['success']),
      output: getString(response['output']),
      errors: errors,
      sandboxId: getString(response['sandboxId']),
      sandboxCreated: getBool(response['sandboxCreated']),
      resumeFailed: getBool(response['resumeFailed']),
      executionTimeMs: getInt(
        response['executionTimeMs'] ?? response['executionTime'],
      ),
      tokensUsed: getInt(metadata?['tokensUsed']),
      creditsUsed: getDouble(metadata?['creditsUsed']),
    );
  }

  static Map<String, dynamic> _extractBestResponse(Map<String, dynamic> message) {
    final dynamic info = message['info'];
    if (info is List && info.isNotEmpty) {
      final dynamic first = info.first;
      if (first is Map) {
        return Map<String, dynamic>.from(first);
      }
    }

    final dynamic msg = message['message'];
    final Map<String, dynamic>? decoded = _decodeJsonObject(msg);
    if (decoded != null) return decoded;

    return message;
  }

  static Map<String, dynamic>? _decodeJsonObject(dynamic value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) return null;
      try {
        final dynamic decoded = jsonDecode(trimmed);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static List<String> _stringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return value.map((e) => getString(e)).where((e) => e.trim().isNotEmpty).toList();
    }
    final String s = getString(value).trim();
    if (s.isEmpty) return const [];
    return [s];
  }
}

