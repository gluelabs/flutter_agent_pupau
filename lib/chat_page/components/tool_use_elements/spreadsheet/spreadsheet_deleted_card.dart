import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpreadsheetDeletedCard extends StatelessWidget {
  const SpreadsheetDeletedCard({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String id = data.row?['id']?.toString() ?? '';
    final String text = id.trim().isNotEmpty
        ? Strings.spreadsheetRowDeletedWithId.trParams({'id': id.trim()})
        : Strings.spreadsheetRowDeleted.tr;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(
            Symbols.delete,
            size: 20,
            color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: StyleService.toolNormalTextStyle(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
