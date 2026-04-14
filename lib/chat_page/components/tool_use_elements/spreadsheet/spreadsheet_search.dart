import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_read_only_data_table.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class SpreadsheetSearchResults extends StatefulWidget {
  const SpreadsheetSearchResults({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  State<SpreadsheetSearchResults> createState() => _SpreadsheetSearchResultsState();
}

class _SpreadsheetSearchResultsState extends State<SpreadsheetSearchResults> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isAnonymous = widget.isAnonymous;
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String fileName = (data.source?.fileName ?? '').trim();
    final int fetched = data.rows.length;
    final int total = data.total > 0 ? data.total : fetched;
    final int visibleCount =
        (fetched).clamp(0, (_page + 1) * _pageSize);
    final List<Map<String, dynamic>> visibleRows =
        data.rows.take(visibleCount).toList();

    final TextStyle headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final TextStyle metaStyle = StyleService.toolNormalTextStyle(isDark);

    final String headerText = fileName.isNotEmpty
        ? Strings.spreadsheetResultsSummary.trParams({
            'fileName': fileName,
            'rowCount': total.toString(),
          })
        : '${Strings.results.tr}: $total';

    final List<String> columnKeys = inferColumnKeys(data);
    final List<String> columnTitles = inferColumnTitles(data, columnKeys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headerText, style: headerStyle),
        if (total > visibleCount && visibleCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${Strings.showing.tr} $visibleCount ${Strings.of.tr} $total',
              style: metaStyle,
            ),
          ),
        const SizedBox(height: 10),
        if (visibleRows.isEmpty)
          Text(Strings.noOutput.tr, style: metaStyle)
        else
          SpreadsheetReadOnlyDataTable(
            columnTitles: columnTitles,
            columnKeys: columnKeys,
            rows: visibleRows,
            isAnonymous: isAnonymous,
          ),
        if (fetched > visibleCount)
          Align(
            alignment: Alignment.centerLeft,
            child: CustomButton(
              onPressed: () => setState(() => _page += 1),
              text: Strings.continue_.tr,
              isPrimary: false,
              textStyle: metaStyle,
            ),
          ),
        if (data.rows.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomButton(
                text: Strings.exportCsv.tr,
                onPressed: () => FileService.exportCsv(
                  fileName.isNotEmpty
                      ? '${fileName.replaceAll('.xlsx', '').replaceAll('.csv', '')}.csv'
                      : 'spreadsheet_search.csv',
                  data.rows,
                ),
              ),
            ),
          ),
      ],
    );
  }

  static List<String> inferColumnKeys(ToolUseSpreadsheetData data) {
    if (data.rows.isNotEmpty) {
      final keys = data.rows.first.keys.toList();
      keys.sort((a, b) {
        if (a == 'id') return -1;
        if (b == 'id') return 1;
        return a.compareTo(b);
      });
      return keys;
    }
    return data.columns
        .map((c) => c.name)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static List<String> inferColumnTitles(
    ToolUseSpreadsheetData data,
    List<String> keys,
  ) {
    final Map<String, String> byName = {
      for (final c in data.columns)
        if (c.name.trim().isNotEmpty)
          c.name.trim(): (c.displayName.trim().isNotEmpty
              ? c.displayName.trim()
              : c.name.trim()),
    };
    return keys.map((k) => byName[k] ?? k).toList();
  }
}
