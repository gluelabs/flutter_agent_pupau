import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_read_only_data_table.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class SpreadsheetSampleCard extends StatefulWidget {
  const SpreadsheetSampleCard({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  State<SpreadsheetSampleCard> createState() => _SpreadsheetSampleCardState();
}

class _SpreadsheetSampleCardState extends State<SpreadsheetSampleCard> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isAnonymous = widget.isAnonymous;
    final bool isDark = Get.isDarkMode || isAnonymous;
    final headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final normalStyle = StyleService.toolNormalTextStyle(isDark);

    final String fileName = (data.source?.fileName ?? '').trim();
    final String sheetName = (data.source?.sheetName ?? '').trim();
    final String sourceLabel = [
      if (fileName.isNotEmpty) fileName,
      if (sheetName.isNotEmpty) sheetName,
    ].join(' · ');

    final int fetched = data.rows.length;
    final int visibleCount =
        fetched.clamp(0, (_page + 1) * _pageSize);
    final List<Map<String, dynamic>> visibleRows =
        data.rows.take(visibleCount).toList();
    final int start = data.offset + (visibleCount > 0 ? 1 : 0);
    final int end = data.offset + visibleCount;
    final String rangeLabel = visibleCount == 0 ? '' : '$start-$end';

    final List<String> columnKeys = _inferColumnKeys(data);
    final List<String> columnTitles = _inferColumnTitles(data, columnKeys);

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sourceLabel.isEmpty ? Strings.results.tr : sourceLabel,
                  style: headerStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              if (rangeLabel.isNotEmpty)
                '${Strings.showing.tr} $rangeLabel',
              if (data.total > 0) '${Strings.nativeDbRows.tr}: ${data.total}',
            ].join(' · '),
            style: normalStyle,
          ),
          const SizedBox(height: 10),
          if (visibleRows.isEmpty)
            Text(Strings.noOutput.tr, style: normalStyle)
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
                textStyle: normalStyle,
              ),
            ),
        ],
      ),
    );
  }

  static List<String> _inferColumnKeys(ToolUseSpreadsheetData data) {
    if (data.rows.isNotEmpty) {
      final keys = data.rows.first.keys.toList();
      keys.sort((a, b) {
        if (a == 'row_id') return -1;
        if (b == 'row_id') return 1;
        return a.compareTo(b);
      });
      return keys;
    }
    return data.columns
        .map((c) => c.name)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static List<String> _inferColumnTitles(
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

