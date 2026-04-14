import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/spreadsheet/spreadsheet_distinct_row.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class SpreadsheetDistinctCard extends StatefulWidget {
  const SpreadsheetDistinctCard({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  State<SpreadsheetDistinctCard> createState() =>
      _SpreadsheetDistinctCardState();
}

class _SpreadsheetDistinctCardState extends State<SpreadsheetDistinctCard> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isAnonymous = widget.isAnonymous;
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String column =
        (data.toolArgs['column'] ?? data.toolArgs['field'] ?? '')
            .toString()
            .trim();
    final int categories = data.distinctItems.length;
    final int total =
        data.distinctItems.fold<int>(0, (acc, e) => acc + e.count);
    final String title = column.isNotEmpty
        ? Strings.spreadsheetDistinctSummary.trParams({
            'column': column,
            'categories': categories.toString(),
            'rows': total.toString(),
          })
        : Strings.spreadsheetDistinct.tr;

    final TextStyle headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final TextStyle metaStyle = StyleService.toolNormalTextStyle(isDark);

    final List<SpreadsheetDistinctItem> items = data.distinctItems;
    final int maxCount = items.isEmpty
        ? 0
        : items.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    final int visibleCount = items.length.clamp(0, (_page + 1) * _pageSize);
    final List<SpreadsheetDistinctItem> visible =
        items.take(visibleCount).toList();
    final int remaining = items.length - visibleCount;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: headerStyle),
          const SizedBox(height: 10),
          for (final item in visible)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SpreadsheetDistinctRow(
                label: item.value.trim().isEmpty
                    ? '(empty)'
                    : item.value.trim(),
                count: item.count,
                total: total,
                max: maxCount,
                metaStyle: metaStyle,
                isAnonymous: isAnonymous,
              ),
            ),
          if (remaining > 0)
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton(
                onPressed: () => setState(() => _page += 1),
                text: Strings.continue_.tr,
                isPrimary: false,
                textStyle: metaStyle,
              ),
            ),
        ],
      ),
    );
  }
}
