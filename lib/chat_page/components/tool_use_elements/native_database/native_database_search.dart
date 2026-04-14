import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class NativeDatabaseSearchResults extends StatefulWidget {
  const NativeDatabaseSearchResults({
    super.key,
    required this.result,
    required this.isAnonymous,
  });

  final NativeDbSearchResult result;
  final bool isAnonymous;

  @override
  State<NativeDatabaseSearchResults> createState() =>
      _NativeDatabaseSearchResultsState();
}

class _NativeDatabaseSearchResultsState extends State<NativeDatabaseSearchResults> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isAnonymous = widget.isAnonymous;
    final bool isDark = Get.isDarkMode || isAnonymous;
    final TextStyle headerStyle = StyleService.toolHeaderTextStyle(isDark);
    final TextStyle metaStyle = StyleService.toolNormalTextStyle(isDark);

    final List<String> columnKeys = inferColumnKeys(result);
    final List<String> columnTitles = inferColumnTitles(result, columnKeys);
    final int fetched = result.rows.length;
    final int total = result.total;
    final int visibleCount = fetched.clamp(0, (_page + 1) * _pageSize);
    final visibleRows = result.rows.take(visibleCount).toList();
    final bool hasDatabaseName = result.databaseName.trim().isNotEmpty;
    final bool hasTotal = total > 0;
    final bool hasNameOrTotal = hasDatabaseName || hasTotal;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasNameOrTotal)
          Row(
            spacing: 6,
            children: [
              if (hasDatabaseName)
                Text(result.databaseName.trim(), style: headerStyle),
              if (hasTotal)
                Text(
                  hasDatabaseName
                      ? '- $total ${Strings.results.tr}'
                      : '$total ${Strings.results.tr}',
                  style: metaStyle,
                ),
            ],
          ),

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
          NativeDatabaseReadOnlyDataTable(
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
        if (result.rows.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: CustomButton(
                text: Strings.exportCsv.tr,
                onPressed: () =>
                    FileService.exportCsv('native_db_search.csv', result.rows),
              ),
            ),
          ),
      ],
    );
  }

  static List<String> inferColumnKeys(NativeDbSearchResult result) {
    if (result.rows.isNotEmpty) {
      final keys = result.rows.first.keys.toList();
      keys.sort((a, b) {
        if (a == 'id') return -1;
        if (b == 'id') return 1;
        return a.compareTo(b);
      });
      return keys;
    }
    return result.columns
        .map((c) => c.name)
        .where((e) => e.trim().isNotEmpty)
        .toList();
  }

  static List<String> inferColumnTitles(
    NativeDbSearchResult result,
    List<String> keys,
  ) {
    final Map<String, String> byName = {
      for (final c in result.columns)
        if (c.name.trim().isNotEmpty)
          c.name.trim(): (c.displayName.trim().isNotEmpty
              ? c.displayName.trim()
              : c.name.trim()),
    };
    return keys.map((k) => byName[k] ?? k).toList();
  }
}

class NativeDatabaseReadOnlyDataTable extends StatelessWidget {
  const NativeDatabaseReadOnlyDataTable({
    super.key,
    required this.columnTitles,
    required this.columnKeys,
    required this.rows,
    required this.isAnonymous,
  });

  final List<String> columnTitles;
  final List<String> columnKeys;
  final List<Map<String, dynamic>> rows;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: StyleService.toolCellHeaderTextStyle(isDark),
          dataTextStyle: StyleService.toolNormalTextStyle(isDark),
          columns: [
            for (final String title in columnTitles)
              DataColumn(
                label: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          rows: [
            for (final Map<String, dynamic> row in rows)
              DataRow(
                cells: [
                  for (final String key in columnKeys)
                    DataCell(
                      Text(
                        (row[key] ?? '').toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
