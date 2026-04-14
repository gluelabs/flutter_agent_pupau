import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpreadsheetInfoCard extends StatelessWidget {
  const SpreadsheetInfoCard({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final normalStyle = StyleService.toolNormalTextStyle(isDark);
    final cellHeaderStyle = StyleService.toolCellHeaderTextStyle(isDark);

    final String fileName = (data.source?.fileName ?? '').trim();
    final String sheetName = (data.source?.sheetName ?? '').trim();
    final String sourceLabel = [
      if (fileName.isNotEmpty) fileName,
      if (sheetName.isNotEmpty) sheetName,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.info, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sourceLabel.isEmpty ? Strings.spreadsheetStats.tr : sourceLabel,
                  style: headerStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${Strings.nativeDbRows.tr}: ${data.totalRows}',
            style: normalStyle,
          ),
          const SizedBox(height: 10),
          Text('${Strings.columns.tr}:', style: cellHeaderStyle),
          const SizedBox(height: 6),
          if (data.columns.isEmpty)
            Text(Strings.noOutput.tr, style: normalStyle)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final c in data.columns)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      [
                        c.displayName.trim().isNotEmpty
                            ? c.displayName.trim()
                            : c.name,
                        if (c.displayName.trim().isNotEmpty &&
                            c.name.trim().isNotEmpty &&
                            c.displayName.trim() != c.name.trim())
                          '(${c.name.trim()})',
                        if (c.type.trim().isNotEmpty) '- ${c.type.trim()}',
                      ].join(' '),
                      style: normalStyle,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

