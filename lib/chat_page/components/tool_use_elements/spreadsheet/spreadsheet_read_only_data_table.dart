import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:get/get.dart';

class SpreadsheetReadOnlyDataTable extends StatelessWidget {
  const SpreadsheetReadOnlyDataTable({
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
    final bool isTablet = DeviceService.isTablet;
    final bool isDark = Get.isDarkMode || isAnonymous;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingTextStyle: StyleService.toolCellHeaderTextStyle(isDark),
          dataTextStyle: StyleService.toolNormalTextStyle(isDark).copyWith(
            fontSize: isTablet ? 14 : 13,
          ),
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
