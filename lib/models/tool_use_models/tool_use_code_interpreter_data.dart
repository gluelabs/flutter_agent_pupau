import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// One inline image returned by the code interpreter (e.g. a matplotlib
/// chart saved by the executed code). Only [isRenderableImage] data URIs
/// should ever be decoded/rendered — anything else must be treated as
/// untrusted and shown as raw text, never as HTML.
class ToolUseCodeInterpreterImage {
  final String dataUri;
  final String description;
  final String format;

  ToolUseCodeInterpreterImage({
    required this.dataUri,
    required this.description,
    required this.format,
  });

  factory ToolUseCodeInterpreterImage.fromJson(Map<String, dynamic> json) =>
      ToolUseCodeInterpreterImage(
        dataUri: getString(json['dataUri']),
        description: getString(json['description']),
        format: getString(json['format']),
      );

  static const List<String> _allowedImageSubtypes = [
    'data:image/png',
    'data:image/jpg',
    'data:image/jpeg',
    'data:image/gif',
    'data:image/webp',
    'data:image/svg',
  ];

  /// Whether [dataUri] is safe to decode/render as an image. Anything that
  /// doesn't start with an allow-listed `data:image/...` prefix must never
  /// be rendered (e.g. as HTML) — show it as raw text instead.
  bool get isRenderableImage {
    final String lower = dataUri.trim().toLowerCase();
    return _allowedImageSubtypes.any(lower.startsWith);
  }

  bool get isSvg => dataUri.trim().toLowerCase().startsWith('data:image/svg');

  /// The base64 payload with the `data:...;base64,` prefix stripped, ready
  /// for `base64Decode`. Only meaningful when [isRenderableImage] is true.
  String get base64Payload {
    final int commaIndex = dataUri.indexOf(',');
    return commaIndex == -1 ? dataUri : dataUri.substring(commaIndex + 1);
  }
}

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
  final List<ToolUseCodeInterpreterImage> images;

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
    required this.images,
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
    final List<ToolUseCodeInterpreterImage> images = response['images'] is List
        ? (response['images'] as List)
              .whereType<Map>()
              .map(
                (e) => ToolUseCodeInterpreterImage.fromJson(
                  Map<String, dynamic>.from(e),
                ),
              )
              .toList()
        : const [];

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
      images: images,
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

