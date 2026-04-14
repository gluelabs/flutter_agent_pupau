import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class NativeDatabaseBulkInsertCard extends StatelessWidget {
  const NativeDatabaseBulkInsertCard({
    super.key,
    required this.result,
    required this.toolArgs,
    required this.isAnonymous,
    required this.databaseName,
  });

  final NativeDbBulkInsertResult? result;
  final Map<String, dynamic> toolArgs;
  final bool isAnonymous;
  final String? databaseName;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final int inserted = result?.inserted ?? 0;
    final int failed = result?.failed ?? 0;
    final List<String> errors = result?.errors ?? const [];
    final List<Map<String, dynamic>> insertedRows =
        result?.insertedRows ?? const [];
    final Color green = MyStyles.pupauTheme(!Get.isDarkMode).green;
    final Color red = MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;
    final bool hasErrors = failed > 0 || errors.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((databaseName ?? '').trim().isNotEmpty) ...[
            Text(
              databaseName!.trim(),
              style: StyleService.toolHeaderTextStyle(isDark),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Icon(
                hasErrors ? Symbols.error : Symbols.check_circle,
                color: hasErrors ? red : green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Strings.nativeDbBulkInsertSummary.tr,
                  style: StyleService.toolHeaderTextStyle(isDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              Text(
                '${Strings.nativeDbInserted.tr}: $inserted',
                style: StyleService.toolNormalTextStyle(isDark),
              ),
              Text(
                '${Strings.failed.tr}: $failed',
                style: StyleService.toolNormalTextStyle(isDark).copyWith(
                  fontWeight: FontWeight.w600,
                  color: hasErrors
                      ? MyStyles.pupauTheme(!Get.isDarkMode).redAlarm
                      : StyleService.toolNormalTextStyle(isDark).color,
                ),
              ),
            ],
          ),
          if (insertedRows.isNotEmpty) ...[
            const SizedBox(height: 4),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: false,
                title: Text(
                  Strings.nativeDbInsertedRows.tr,
                  style: StyleService.toolCellHeaderTextStyle(isDark),
                ),
                children: [
                  _PagedInsertedRows(
                    insertedRows: insertedRows,
                    isAnonymous: isAnonymous,
                  ),
                ],
              ),
            ),
          ],
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 10),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: EdgeInsets.zero,
                initiallyExpanded: false,
                title: Text(
                  Strings.errors.tr,
                  style: StyleService.toolCellHeaderTextStyle(isDark),
                ),
                children: [
                  ...errors.map(
                    (e) => Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          e,
                          style: StyleService.toolNormalTextStyle(isDark),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class NativeDatabaseInsertedRowPreview extends StatelessWidget {
  const NativeDatabaseInsertedRowPreview({
    super.key,
    required this.row,
    required this.isAnonymous,
  });

  final Map<String, dynamic> row;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final List<MapEntry<String, dynamic>> preview = row.entries
        .where((e) => e.key != 'error')
        .toList();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview.isNotEmpty) ...[
            Wrap(
              spacing: 10,
              runSpacing: 6,
              children: preview
                  .map(
                    (e) => Text(
                      '${e.key}: ${e.value}',
                      style: StyleService.toolNormalTextStyle(isDark),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PagedInsertedRows extends StatefulWidget {
  const _PagedInsertedRows({
    required this.insertedRows,
    required this.isAnonymous,
  });

  final List<Map<String, dynamic>> insertedRows;
  final bool isAnonymous;

  @override
  State<_PagedInsertedRows> createState() => _PagedInsertedRowsState();
}

class _PagedInsertedRowsState extends State<_PagedInsertedRows> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || widget.isAnonymous;
    final int visibleCount =
        widget.insertedRows.length.clamp(0, (_page + 1) * _pageSize);
    final visible = widget.insertedRows.take(visibleCount).toList();
    final bool hasMore = widget.insertedRows.length > visibleCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: NativeDatabaseInsertedRowPreview(
                row: row,
                isAnonymous: widget.isAnonymous,
              ),
            ),
          ),
        if (hasMore)
          Align(
            alignment: Alignment.centerLeft,
            child: CustomButton(
              onPressed: () => setState(() => _page += 1),
              text: Strings.continue_.tr,
              isPrimary: false,
              textStyle: StyleService.toolNormalTextStyle(isDark),
            ),
          ),
      ],
    );
  }
}
