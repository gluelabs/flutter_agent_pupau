import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_bulk_insert.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_compact_status.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_created.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_error_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_row_confirmation.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_search.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_spreadsheet.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info_list.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/native_database_registry_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class MessageNativeDatabase extends StatelessWidget {
  const MessageNativeDatabase({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    if (toolUseMessage?.spreadsheetData != null) {
      return MessageSpreadsheet(
        toolUseMessage: toolUseMessage,
        isAnonymous: isAnonymous,
      );
    }
    final ToolUseNativeDatabaseData? data = toolUseMessage?.nativeDatabaseData;
    if (data == null) return const SizedBox.shrink();
    final int databaseId = _extractDatabaseId(data.toolArgs);
    final String? databaseName = _resolveDatabaseName(
      explicitName: data.searchResult?.databaseName,
      databaseId: databaseId,
    );

    switch (data.resultType) {
      case NativeDbToolResultType.error:
        return NativeDatabaseErrorBox(
          message: data.errorMessage ?? (data.raw?['error']?.toString() ?? ''),
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.dbList:
        return NativeDatabaseListView(
          databases: data.databases,
          isAnonymous: isAnonymous,
        );
      case NativeDbToolResultType.search:
        final result = data.searchResult;
        if (result == null) return const SizedBox.shrink();
        return NativeDatabaseSearchResults(
          result: result,
          isAnonymous: isAnonymous,
        );
      case NativeDbToolResultType.rowCreated:
        return NativeDatabaseRowConfirmationCard(
          title: Strings.nativeDbRowInserted.tr,
          icon: Symbols.check_circle,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).green,
          row: data.row ?? const {},
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.bulkInsert:
        return NativeDatabaseBulkInsertCard(
          result: data.bulkInsertResult,
          toolArgs: data.toolArgs,
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.rowUpdated:
        return NativeDatabaseRowConfirmationCard(
          title: Strings.nativeDbRowUpdated.tr,
          icon: Symbols.edit,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).green,
          row: data.row ?? const {},
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.rowDeleted:
        return NativeDatabaseCompactStatusCard(
          title: Strings.nativeDbRowDeleted.tr,
          icon: Symbols.check_circle,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).green,
          subtitle: data.message,
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.dbCreated:
        final db = data.createdDatabase;
        if (db == null) return const SizedBox.shrink();
        return NativeDatabaseCreatedCard(
          database: db,
          isAnonymous: isAnonymous,
        );
      case NativeDbToolResultType.columnAdded:
        final col = data.addedColumn;
        if (col == null) return const SizedBox.shrink();
        return NativeDatabaseCompactStatusCard(
          title: Strings.nativeDbColumnAdded.tr,
          icon: Symbols.check_circle,
          iconColor: MyStyles.pupauTheme(!Get.isDarkMode).green,
          subtitle:
              '${col.displayName.isNotEmpty ? col.displayName : col.name} [${col.type}]',
          isAnonymous: isAnonymous,
          databaseName: databaseName,
        );
      case NativeDbToolResultType.raw:
        return ToolUseInfoList(
          infoList: toolUseMessage?.nativeToolData ?? const {},
          isAnonymous: isAnonymous,
          forceExpanded: true,
        );
    }
  }

  static int _extractDatabaseId(Map<String, dynamic> toolArgs) {
    final dynamic v = toolArgs['database_id'] ?? toolArgs['databaseId'];
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static String? _resolveDatabaseName({
    required String? explicitName,
    required int databaseId,
  }) {
    final String name = (explicitName ?? '').trim();
    if (name.isNotEmpty) return name;
    final String? cached = NativeDatabaseRegistryService.getDatabaseName(databaseId);
    if ((cached ?? '').trim().isNotEmpty) return cached!.trim();
    if (databaseId > 0) return 'Database #$databaseId';
    return null;
  }
}

