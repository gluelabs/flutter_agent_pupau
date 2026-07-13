import 'dart:convert';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class ToolUseMemoryProfileData {
  final String toolName;
  final String action; // SEARCH | CREATE | UPDATE | DELETE
  final String query;
  final String memory;
  final String message;
  final List<String> errors;

  ToolUseMemoryProfileData({
    required this.toolName,
    required this.action,
    required this.query,
    required this.memory,
    required this.message,
    required this.errors,
  });

  factory ToolUseMemoryProfileData.fromToolUseMessage({
    required Map<String, dynamic> message,
    required Map<String, dynamic>? typeDetails,
  }) {
    final Map<String, dynamic> toolArgs = typeDetails?["toolArgs"] is Map
        ? Map<String, dynamic>.from(typeDetails?["toolArgs"] as Map)
        : <String, dynamic>{};

    final String toolName = getString(typeDetails?["toolName"]);
    final String action =
        getString(toolArgs["action"]).trim().isEmpty ? getString(message["action"]) : getString(toolArgs["action"]);

    final String query = getString(toolArgs["query"]).trim().isEmpty
        ? getString(message["query"])
        : getString(toolArgs["query"]);
    final String memory = getString(toolArgs["memory"]).trim().isEmpty
        ? getString(message["memory"])
        : getString(toolArgs["memory"]);

    String msg = getString(message["message"]);
    if (msg.trim().isEmpty && message["info"] is List) {
      final List<dynamic> info = message["info"] as List<dynamic>;
      if (info.isNotEmpty && info.first is String) {
        msg = (info.first as String).trim();
      }
    }

    final List<String> errors = <String>[];
    final dynamic rawErrors = message["errors"];
    if (rawErrors is List) {
      for (final dynamic e in rawErrors) {
        final String s = getString(e).trim();
        if (s.isNotEmpty) errors.add(s);
      }
    } else if (rawErrors is String) {
      final String s = rawErrors.trim();
      if (s.isNotEmpty) errors.add(s);
    }

    // Some backends wrap a JSON string under `message.message`.
    if (msg.trim().startsWith('{') && msg.trim().endsWith('}')) {
      try {
        final dynamic decoded = jsonDecode(msg);
        if (decoded is Map) {
          final Map<String, dynamic> decodedMap =
              Map<String, dynamic>.from(decoded);
          final String nested = getString(decodedMap["message"]).trim();
          if (nested.isNotEmpty) {
            msg = nested;
          }
        }
      } catch (_) {
        // ignore
      }
    }

    return ToolUseMemoryProfileData(
      toolName: toolName.trim().isEmpty ? "memory" : toolName,
      action: action,
      query: query,
      memory: memory,
      message: msg,
      errors: errors,
    );
  }

  bool get hasError => errors.isNotEmpty || message.toLowerCase().startsWith('error:');
}

