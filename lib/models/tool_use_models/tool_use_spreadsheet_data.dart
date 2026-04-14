import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

enum SpreadsheetToolResultType {
  error,
  info,
  sample,
  search,
  rowCreated,
  rowUpdated,
  rowDeleted,
  summary,
  distinct,
  raw,
}

class SpreadsheetSourceInfo {
  final String fileName;
  final String sheetName;
  final int attachmentId;

  SpreadsheetSourceInfo({
    required this.fileName,
    required this.sheetName,
    required this.attachmentId,
  });

  factory SpreadsheetSourceInfo.fromJson(Map<String, dynamic> json) {
    return SpreadsheetSourceInfo(
      fileName: getString(json['fileName']),
      sheetName: getString(json['sheetName']),
      attachmentId: getInt(json['attachmentId']),
    );
  }
}

class SpreadsheetColumnInfo {
  final String name;
  final String displayName;
  final String type;

  SpreadsheetColumnInfo({
    required this.name,
    required this.displayName,
    required this.type,
  });

  factory SpreadsheetColumnInfo.fromJson(Map<String, dynamic> json) {
    return SpreadsheetColumnInfo(
      name: getString(json['name']),
      displayName: getString(json['displayName']),
      type: getString(json['type']),
    );
  }
}

class SpreadsheetSummaryItem {
  final String column;
  final int count;
  final double? sum;
  final double? avg;
  final double? min;
  final double? max;

  SpreadsheetSummaryItem({
    required this.column,
    required this.count,
    this.sum,
    this.avg,
    this.min,
    this.max,
  });

  factory SpreadsheetSummaryItem.fromJson(Map<String, dynamic> json) {
    double? toDoubleOrNull(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return SpreadsheetSummaryItem(
      column: getString(json['column']),
      count: getInt(json['count']),
      sum: toDoubleOrNull(json['sum']),
      avg: toDoubleOrNull(json['avg']),
      min: toDoubleOrNull(json['min']),
      max: toDoubleOrNull(json['max']),
    );
  }
}

class SpreadsheetDistinctItem {
  final String value;
  final int count;

  SpreadsheetDistinctItem({
    required this.value,
    required this.count,
  });

  factory SpreadsheetDistinctItem.fromJson(Map<String, dynamic> json) {
    return SpreadsheetDistinctItem(
      value: getString(json['value']),
      count: getInt(json['count']),
    );
  }
}

class ToolUseSpreadsheetData {
  final String toolName;
  final Map<String, dynamic> toolArgs;

  final SpreadsheetToolResultType resultType;
  final String? errorMessage;

  final SpreadsheetSourceInfo? source;
  final List<SpreadsheetColumnInfo> columns;
  final List<Map<String, dynamic>> rows;
  final int total;
  final int totalRows;
  final int offset;
  final int limit;

  final Map<String, dynamic>? row;
  final String? message;

  final List<SpreadsheetSummaryItem> summaryItems;
  final List<SpreadsheetDistinctItem> distinctItems;

  final dynamic raw;

  ToolUseSpreadsheetData({
    required this.toolName,
    required this.toolArgs,
    required this.resultType,
    this.errorMessage,
    this.source,
    this.columns = const [],
    this.rows = const [],
    this.total = 0,
    this.totalRows = 0,
    this.offset = 0,
    this.limit = 0,
    this.row,
    this.message,
    this.summaryItems = const [],
    this.distinctItems = const [],
    this.raw,
  });

  factory ToolUseSpreadsheetData.fromToolUseMessage({
    required String toolName,
    required Map<String, dynamic> message,
    required Map<String, dynamic>? typeDetails,
  }) {
    final Map<String, dynamic> toolArgs =
        typeDetails?['toolArgs'] is Map ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map) : const {};
    final dynamic decoded = _extractDecodedResult(message);

    if (decoded is Map && decoded['error'] != null) {
      final String err = getString(decoded['error']).trim();
      return ToolUseSpreadsheetData(
        toolName: toolName,
        toolArgs: toolArgs,
        resultType: SpreadsheetToolResultType.error,
        errorMessage: err.isEmpty ? null : err,
        raw: decoded,
      );
    }

    switch (toolName.trim()) {
      case 'spreadsheet_info':
        if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          final SpreadsheetSourceInfo? source = map['source'] is Map
              ? SpreadsheetSourceInfo.fromJson(
                  Map<String, dynamic>.from(map['source'] as Map),
                )
              : null;
          final List cols =
              map['columns'] is List ? (map['columns'] as List) : const [];
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.info,
            source: source,
            columns: cols
                .whereType<Map>()
                .map(
                  (e) => SpreadsheetColumnInfo.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(),
            totalRows: getInt(map['totalRows']),
            raw: map,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_sample':
        if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          final SpreadsheetSourceInfo? source = map['source'] is Map
              ? SpreadsheetSourceInfo.fromJson(
                  Map<String, dynamic>.from(map['source'] as Map),
                )
              : null;
          final List cols =
              map['columns'] is List ? (map['columns'] as List) : const [];
          final List rows = map['rows'] is List ? (map['rows'] as List) : const [];
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.sample,
            source: source,
            columns: cols
                .whereType<Map>()
                .map(
                  (e) => SpreadsheetColumnInfo.fromJson(
                    Map<String, dynamic>.from(e),
                  ),
                )
                .toList(),
            rows: rows
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
            total: getInt(map['total']),
            offset: getInt(map['offset']),
            limit: getInt(map['limit']),
            raw: map,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_search':
        if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          final SpreadsheetSourceInfo? source = map['source'] is Map
              ? SpreadsheetSourceInfo.fromJson(
                  Map<String, dynamic>.from(map['source'] as Map),
                )
              : null;
          final List cols = map['columns'] is List ? (map['columns'] as List) : const [];
          final List rows = map['rows'] is List ? (map['rows'] as List) : const [];
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.search,
            source: source,
            columns: cols
                .whereType<Map>()
                .map((e) => SpreadsheetColumnInfo.fromJson(Map<String, dynamic>.from(e)))
                .toList(),
            rows: rows
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList(),
            total: getInt(map['total']),
            raw: map,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_insert':
        if (decoded is Map) {
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.rowCreated,
            row: Map<String, dynamic>.from(decoded),
            raw: decoded,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_update':
        if (decoded is Map) {
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.rowUpdated,
            row: Map<String, dynamic>.from(decoded),
            raw: decoded,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_delete':
        if (decoded is Map) {
          final Map<String, dynamic> map = Map<String, dynamic>.from(decoded);
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.rowDeleted,
            message: getString(map['message']).trim().isEmpty ? null : getString(map['message']),
            row: map.containsKey('id') ? map : null,
            raw: map,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_summary':
        if (decoded is List) {
          final items = decoded
              .whereType<Map>()
              .map((e) => SpreadsheetSummaryItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.summary,
            summaryItems: items,
            raw: decoded,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      case 'spreadsheet_distinct':
        if (decoded is List) {
          final items = decoded
              .whereType<Map>()
              .map((e) => SpreadsheetDistinctItem.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          return ToolUseSpreadsheetData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: SpreadsheetToolResultType.distinct,
            distinctItems: items,
            raw: decoded,
          );
        }
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );

      default:
        return ToolUseSpreadsheetData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: SpreadsheetToolResultType.raw,
          raw: decoded,
        );
    }
  }

  static dynamic _extractDecodedResult(Map<String, dynamic> message) {
    if (message.containsKey('message')) {
      final dynamic msg = message['message'];
      if (msg is List) return msg;
      if (msg is Map) return Map<String, dynamic>.from(msg);
      final dynamic decoded = _tryDecodeJson(msg);
      return decoded ?? msg;
    }
    return message;
  }

  static dynamic _tryDecodeJson(dynamic value) {
    if (value == null) return null;
    if (value is Map || value is List) return value;
    if (value is String) {
      final String trimmed = value.trim();
      if (trimmed.isEmpty) return null;
      if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) return null;
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

