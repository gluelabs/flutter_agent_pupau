import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_spreadsheet_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpreadsheetSummaryCard extends StatefulWidget {
  const SpreadsheetSummaryCard({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseSpreadsheetData data;
  final bool isAnonymous;

  @override
  State<SpreadsheetSummaryCard> createState() => _SpreadsheetSummaryCardState();
}

class _SpreadsheetSummaryCardState extends State<SpreadsheetSummaryCard> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isAnonymous = widget.isAnonymous;
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String fileName = (data.toolArgs['fileName'] ??
            data.toolArgs['sourceFileName'] ??
            '')
        .toString()
        .trim();
    final String title = fileName.isNotEmpty
        ? Strings.spreadsheetStatsSummary.trParams({'fileName': fileName})
        : '';

    final TextStyle headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final TextStyle metaStyle = StyleService.toolNormalTextStyle(isDark);

    final locale = Get.locale?.toLanguageTag();
    String fmtNum(num v) => NumberFormat.decimalPattern(locale).format(v);
    String fmtMoney(num v) =>
        NumberFormat.currency(locale: locale, symbol: '€').format(v);

    bool looksLikeMoney(String columnName) {
      final c = columnName.trim().toLowerCase();
      return c.contains('importo') ||
          c.contains('prezzo') ||
          c.contains('costo') ||
          c.contains('totale');
    }

    final int visibleCount =
        data.summaryItems.length.clamp(0, (_page + 1) * _pageSize);
    final visibleItems = data.summaryItems.take(visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.bar_chart, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title.isEmpty ? Strings.spreadsheetStats.tr : title,
                  style: headerStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in visibleItems)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.column.trim().isNotEmpty
                        ? item.column.trim()
                        : Strings.columns.tr,
                    style: headerStyle,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      Text(
                        '${Strings.nativeDbRows.tr}: ${fmtNum(item.count)}',
                        style: metaStyle,
                      ),
                      if (item.sum != null)
                        Text(
                          '${Strings.spreadsheetTotal.tr}: ${looksLikeMoney(item.column) ? fmtMoney(item.sum!) : fmtNum(item.sum!)}',
                          style: metaStyle,
                        ),
                      if (item.avg != null)
                        Text(
                          '${Strings.spreadsheetAverage.tr}: ${looksLikeMoney(item.column) ? fmtMoney(item.avg!) : fmtNum(item.avg!)}',
                          style: metaStyle,
                        ),
                      if (item.min != null)
                        Text(
                          '${Strings.spreadsheetMin.tr}: ${looksLikeMoney(item.column) ? fmtMoney(item.min!) : fmtNum(item.min!)}',
                          style: metaStyle,
                        ),
                      if (item.max != null)
                        Text(
                          '${Strings.spreadsheetMax.tr}: ${looksLikeMoney(item.column) ? fmtMoney(item.max!) : fmtNum(item.max!)}',
                          style: metaStyle,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          if (data.summaryItems.length > visibleCount)
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
