import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/native_database_registry_service.dart';

enum NativeDbToolResultType {
  error,
  dbList,
  search,
  rowCreated,
  bulkInsert,
  rowUpdated,
  rowDeleted,
  dbCreated,
  columnAdded,
  raw,
}

class ToolUseNativeDatabaseData {
  final String toolName;
  final Map<String, dynamic> toolArgs;

  final NativeDbToolResultType resultType;

  final String? errorMessage;

  final List<NativeDbListItem> databases;
  final NativeDbSearchResult? searchResult;
  final Map<String, dynamic>? row;
  final NativeDbBulkInsertResult? bulkInsertResult;
  final String? message;
  final NativeDbCreatedDatabase? createdDatabase;
  final NativeDbColumn? addedColumn;
  final dynamic raw;

  ToolUseNativeDatabaseData({
    required this.toolName,
    required this.toolArgs,
    required this.resultType,
    this.errorMessage,
    this.databases = const [],
    this.searchResult,
    this.row,
    this.bulkInsertResult,
    this.message,
    this.createdDatabase,
    this.addedColumn,
    this.raw,
  });

  factory ToolUseNativeDatabaseData.fromToolUseMessage({
    required String toolName,
    required Map<String, dynamic> message,
    required Map<String, dynamic>? typeDetails,
  }) {
    final Map<String, dynamic> toolArgs =
        typeDetails?['toolArgs'] is Map ? Map<String, dynamic>.from(typeDetails?['toolArgs'] as Map) : const {};

    final dynamic decoded = _extractDecodedResult(message);

    // Error: `{ "error": "..." }`
    if (decoded is Map && decoded['error'] != null) {
      return ToolUseNativeDatabaseData(
        toolName: toolName,
        toolArgs: toolArgs,
        resultType: NativeDbToolResultType.error,
        errorMessage: getString(decoded['error']).trim().isEmpty ? null : getString(decoded['error']),
        raw: decoded,
      );
    }

    switch (toolName.trim()) {
      case 'native_db_list':
        if (decoded is List) {
          final List<NativeDbListItem> parsed = decoded
              .whereType<Map>()
              .map((e) => NativeDbListItem.fromJson(
                    Map<String, dynamic>.from(e),
                  ))
              .toList();
          for (final db in parsed) {
            NativeDatabaseRegistryService.upsertDatabaseName(
              databaseId: db.id,
              databaseName: db.name,
            );
          }
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.dbList,
            databases: parsed,
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_search':
        if (decoded is Map) {
          final search = NativeDbSearchResult.fromJson(Map<String, dynamic>.from(decoded));
          NativeDatabaseRegistryService.upsertDatabaseName(
            databaseId: search.databaseId,
            databaseName: search.databaseName,
          );
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.search,
            searchResult: search,
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_insert':
      case 'native_db_bulk_insert':
        if (decoded is Map) {
          final Map<String, dynamic> decodedMap =
              Map<String, dynamic>.from(decoded);
          if (_looksLikeBulkInsertResult(decodedMap)) {
            return ToolUseNativeDatabaseData(
              toolName: toolName,
              toolArgs: toolArgs,
              resultType: NativeDbToolResultType.bulkInsert,
              bulkInsertResult: NativeDbBulkInsertResult.fromJson(
                decodedMap,
              ),
              raw: decodedMap,
            );
          }
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: toolName.trim() == 'native_db_bulk_insert'
                ? NativeDbToolResultType.raw
                : NativeDbToolResultType.rowCreated,
            row: decodedMap,
            raw: decodedMap,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_update':
        if (decoded is Map) {
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.rowUpdated,
            row: Map<String, dynamic>.from(decoded),
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_delete':
        if (decoded is Map) {
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.rowDeleted,
            message: getString(decoded['message']).trim().isEmpty ? null : getString(decoded['message']),
            row: decoded.containsKey('id') ? Map<String, dynamic>.from(decoded) : null,
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_create_database':
        if (decoded is Map) {
          final NativeDbCreatedDatabase created = NativeDbCreatedDatabase.fromJson(
            Map<String, dynamic>.from(decoded),
          );
          NativeDatabaseRegistryService.upsertDatabaseName(
            databaseId: created.id,
            databaseName: created.name,
          );
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.dbCreated,
            createdDatabase: created,
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      case 'native_db_add_column':
        if (decoded is Map) {
          return ToolUseNativeDatabaseData(
            toolName: toolName,
            toolArgs: toolArgs,
            resultType: NativeDbToolResultType.columnAdded,
            addedColumn: NativeDbColumn.fromJson(Map<String, dynamic>.from(decoded)),
            raw: decoded,
          );
        }
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );

      default:
        return ToolUseNativeDatabaseData(
          toolName: toolName,
          toolArgs: toolArgs,
          resultType: NativeDbToolResultType.raw,
          raw: decoded,
        );
    }
  }

  static dynamic _extractDecodedResult(Map<String, dynamic> message) {
    // `ToolUseMessage.getMessage()` returns:
    // - decoded Map when possible
    // - {"message": decodedList} for list results
    // - {"message": "..."} for non-JSON
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

  static bool _looksLikeBulkInsertResult(Map<String, dynamic> json) {
    final bool hasInserted = json.containsKey('inserted');
    final bool hasFailed = json.containsKey('failed');
    final dynamic rows = json['rows'];
    return hasInserted && hasFailed && rows is List;
  }
}

class NativeDbListItem {
  final int id;
  final String name;
  final String description;
  final List<NativeDbColumnSchema> columns;
  final List<String> allowedOperations;

  NativeDbListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.columns,
    required this.allowedOperations,
  });

  factory NativeDbListItem.fromJson(Map<String, dynamic> json) {
    final List cols = json['columns'] is List ? (json['columns'] as List) : const [];
    final List ops = json['allowedOperations'] is List ? (json['allowedOperations'] as List) : const [];
    return NativeDbListItem(
      id: getInt(json['id']),
      name: getString(json['name']),
      description: getString(json['description']),
      columns: cols
          .whereType<Map>()
          .map((e) => NativeDbColumnSchema.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      allowedOperations: ops.map((e) => getString(e)).where((e) => e.trim().isNotEmpty).toList(),
    );
  }
}

class NativeDbBulkInsertResult {
  final int inserted;
  final int failed;
  final List<String> errors;
  final List<Map<String, dynamic>> insertedRows;

  NativeDbBulkInsertResult({
    required this.inserted,
    required this.failed,
    required this.errors,
    required this.insertedRows,
  });

  factory NativeDbBulkInsertResult.fromJson(Map<String, dynamic> json) {
    final List rows = json['rows'] is List ? (json['rows'] as List) : const [];
    final List<Map<String, dynamic>> insertedRows = rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .where((m) => (getString(m['error']).trim()).isEmpty)
        .toList();
    final List<String> errors = rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map((m) => getString(m['error']).trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return NativeDbBulkInsertResult(
      inserted: getInt(json['inserted']),
      failed: getInt(json['failed']),
      errors: errors,
      insertedRows: insertedRows,
    );
  }
}

class NativeDbColumnSchema {
  final String name;
  final String displayName;
  final String type;
  final bool required;
  final List<String> enumValues;

  NativeDbColumnSchema({
    required this.name,
    required this.displayName,
    required this.type,
    required this.required,
    required this.enumValues,
  });

  factory NativeDbColumnSchema.fromJson(Map<String, dynamic> json) {
    final List enums = json['enumValues'] is List ? (json['enumValues'] as List) : const [];
    return NativeDbColumnSchema(
      name: getString(json['name']),
      displayName: getString(json['displayName']),
      type: getString(json['type']),
      required: getBool(json['required']),
      enumValues: enums.map((e) => getString(e)).where((e) => e.trim().isNotEmpty).toList(),
    );
  }
}

class NativeDbSearchResult {
  final int databaseId;
  final String databaseName;
  final List<NativeDbColumnSchema> columns;
  final List<Map<String, dynamic>> rows;
  final int total;

  NativeDbSearchResult({
    required this.databaseId,
    required this.databaseName,
    required this.columns,
    required this.rows,
    required this.total,
  });

  factory NativeDbSearchResult.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> db =
        json['database'] is Map ? Map<String, dynamic>.from(json['database'] as Map) : const {};
    final List cols = json['columns'] is List ? (json['columns'] as List) : const [];
    final List rows = json['rows'] is List ? (json['rows'] as List) : const [];
    return NativeDbSearchResult(
      databaseId: getInt(db['id']),
      databaseName: getString(db['name']),
      columns: cols
          .whereType<Map>()
          .map((e) {
            final map = Map<String, dynamic>.from(e);
            // Search columns don't include `required` reliably; default false.
            map.putIfAbsent('required', () => false);
            return NativeDbColumnSchema.fromJson(map);
          })
          .toList(),
      rows: rows
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      total: getInt(json['total']),
    );
  }
}

class NativeDbCreatedDatabase {
  final int id;
  final String name;
  final String description;
  final List<NativeDbCreatedColumn> columns;

  NativeDbCreatedDatabase({
    required this.id,
    required this.name,
    required this.description,
    required this.columns,
  });

  factory NativeDbCreatedDatabase.fromJson(Map<String, dynamic> json) {
    final List cols = json['columns'] is List ? (json['columns'] as List) : const [];
    return NativeDbCreatedDatabase(
      id: getInt(json['id']),
      name: getString(json['name']),
      description: getString(json['description']),
      columns: cols
          .whereType<Map>()
          .map((e) => NativeDbCreatedColumn.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class NativeDbCreatedColumn {
  final String name;
  final String displayName;
  final String type;

  NativeDbCreatedColumn({
    required this.name,
    required this.displayName,
    required this.type,
  });

  factory NativeDbCreatedColumn.fromJson(Map<String, dynamic> json) {
    return NativeDbCreatedColumn(
      name: getString(json['name']),
      displayName: getString(json['displayName']),
      type: getString(json['type']),
    );
  }
}

class NativeDbColumn {
  final int id;
  final String name;
  final String displayName;
  final String type;

  NativeDbColumn({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
  });

  factory NativeDbColumn.fromJson(Map<String, dynamic> json) {
    return NativeDbColumn(
      id: getInt(json['id']),
      name: getString(json['name']),
      displayName: getString(json['displayName']),
      type: getString(json['type']),
    );
  }
}

