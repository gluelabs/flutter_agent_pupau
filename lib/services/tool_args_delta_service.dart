import 'dart:convert';

import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_args_delta_data.dart';

class ToolArgsDeltaService {
  static ToolArgsDeltaComputation computePreview({
    required String previousBuffer,
    required String argsDelta,
  }) {
    final String fullBuffer = previousBuffer + argsDelta;
    final Map<String, dynamic>? parsed = tryParseToolArgs(fullBuffer);
    final String? preview = extractDocumentPreview(fullBuffer, parsed);
    final String? title = extractDocumentTitle(parsed);
    return ToolArgsDeltaComputation(
      fullBuffer: fullBuffer,
      preview: preview,
      title: title,
      size: fullBuffer.length,
    );
  }

  static Map<String, dynamic>? tryParseToolArgs(String raw) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  static String? extractDocumentTitle(Map<String, dynamic>? parsed) {
    if (parsed == null) return null;
    for (final String key in const <String>[
      'fileName',
      'filename',
      'name',
      'title',
    ]) {
      final String value = (parsed[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static String? extractDocumentPreview(
    String rawBuffer,
    Map<String, dynamic>? parsed,
  ) {
    if (parsed != null) {
      final dynamic content = parsed['content'];
      if (content is String && content.trim().isNotEmpty) return content;
    }

    final int contentKeyIndex = rawBuffer.indexOf('"content"');
    if (contentKeyIndex < 0) return null;
    final int colonIndex = rawBuffer.indexOf(':', contentKeyIndex);
    if (colonIndex < 0) return null;
    final int firstQuote = rawBuffer.indexOf('"', colonIndex + 1);
    if (firstQuote < 0) return null;

    final StringBuffer preview = StringBuffer();
    bool escaped = false;
    for (int i = firstQuote + 1; i < rawBuffer.length; i++) {
      final String ch = rawBuffer[i];
      if (escaped) {
        switch (ch) {
          case 'n':
            preview.write('\n');
            break;
          case 'r':
            preview.write('\r');
            break;
          case 't':
            preview.write('\t');
            break;
          case '"':
            preview.write('"');
            break;
          case '\\':
            preview.write('\\');
            break;
          default:
            preview.write(ch);
            break;
        }
        escaped = false;
        continue;
      }
      if (ch == '\\') {
        escaped = true;
        continue;
      }
      if (ch == '"') {
        break;
      }
      preview.write(ch);
    }

    final String result = preview.toString();
    return result.trim().isEmpty ? null : result;
  }

  /// Extracts the first JSON string value from a single-key object fragment,
  /// e.g. `{ "thought": "Hello` -> returns `Hello` (best-effort, supports partial).
  ///
  /// This is used for Thinking delta-args where the payload is always a key/value
  /// pair but we don't want to show `{ "key": "` in the UI.
  static String? extractFirstJsonStringValue(String rawBuffer) {
    try {
      if (rawBuffer.trim().isEmpty) return rawBuffer;
      final int firstKeyQuote = rawBuffer.indexOf('"');
      if (firstKeyQuote < 0) return null;
      final int colonIndex = rawBuffer.indexOf(':', firstKeyQuote + 1);
      if (colonIndex < 0) return null;
      final int firstValueQuote = rawBuffer.indexOf('"', colonIndex + 1);
      if (firstValueQuote < 0) return null;

      final StringBuffer value = StringBuffer();
      bool escaped = false;
      for (int i = firstValueQuote + 1; i < rawBuffer.length; i++) {
        final String ch = rawBuffer[i];
        if (escaped) {
          switch (ch) {
            case 'n':
              value.write('\n');
              break;
            case 'r':
              value.write('\r');
              break;
            case 't':
              value.write('\t');
              break;
            case '"':
              value.write('"');
              break;
            case '\\':
              value.write('\\');
              break;
            default:
              value.write(ch);
              break;
          }
          escaped = false;
          continue;
        }
        if (ch == '\\') {
          escaped = true;
          continue;
        }
        if (ch == '"') {
          break;
        }
        value.write(ch);
      }

      final String result = value.toString();
      return result.trim().isEmpty ? rawBuffer : result;
    } catch (e) {
      return rawBuffer;
    }
  }

  static bool hasPreview({
    required String toolId,
    required Map<String, String> previewsById,
    required Map<String, String> rawBuffersById,
  }) {
    if ((previewsById[toolId] ?? '').trim().isNotEmpty) return true;
    return (rawBuffersById[toolId] ?? '').trim().isNotEmpty;
  }

  static String resolveToolIdByName({
    required String toolName,
    required Map<String, String> toolIdByName,
  }) => (toolIdByName[toolName] ?? '').trim();

  static bool hasPreviewForToolName({
    required String toolName,
    required Map<String, String> toolIdByName,
    required Map<String, String> previewsById,
    required Map<String, String> rawBuffersById,
  }) {
    final String toolId = resolveToolIdByName(
      toolName: toolName,
      toolIdByName: toolIdByName,
    );
    if (toolId.isEmpty) return false;
    return hasPreview(
      toolId: toolId,
      previewsById: previewsById,
      rawBuffersById: rawBuffersById,
    );
  }

  static String getPreviewContent({
    required String toolId,
    required Map<String, String> previewsById,
    required Map<String, String> rawBuffersById,
  }) {
    final String parsed = previewsById[toolId] ?? '';
    if (parsed.trim().isNotEmpty) return parsed;
    return rawBuffersById[toolId] ?? '';
  }

  static String getPreviewTitle({
    required String toolId,
    required Map<String, String> titlesById,
  }) {
    return titlesById[toolId] ?? '';
  }

  static void clearPreviewCache({
    required Map<String, String> toolIdByName,
    required Map<String, String> previewsById,
    required Map<String, String> titlesById,
    required Map<String, String> rawBuffersById,
  }) {
    toolIdByName.clear();
    previewsById.clear();
    titlesById.clear();
    rawBuffersById.clear();
  }
}
