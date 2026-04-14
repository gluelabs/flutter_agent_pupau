import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

import 'native_database_shared_widgets.dart';

class NativeDatabaseListView extends StatefulWidget {
  const NativeDatabaseListView({
    super.key,
    required this.databases,
    required this.isAnonymous,
  });

  final List<NativeDbListItem> databases;
  final bool isAnonymous;

  @override
  State<NativeDatabaseListView> createState() => _NativeDatabaseListViewState();
}

class _NativeDatabaseListViewState extends State<NativeDatabaseListView> {
  static const int _pageSize = 20;
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || widget.isAnonymous;
    final databases = widget.databases;
    if (databases.isEmpty) {
      return Text(
        Strings.noOutput.tr,
        style: StyleService.toolNormalTextStyle(isDark),
      );
    }

    final int visibleCount = databases.length.clamp(0, (_page + 1) * _pageSize);
    final visible = databases.take(visibleCount).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          ...visible.map(
            (db) => NativeDatabaseCard(
              database: db,
              isAnonymous: widget.isAnonymous,
              isSingleDatabase: databases.length == 1,
            ),
          ),
          if (databases.length > visibleCount)
            Align(
              alignment: Alignment.centerLeft,
              child: CustomButton(
                onPressed: () => setState(() => _page += 1),
                text: Strings.continue_.tr,
                isPrimary: false,
              ),
            ),
        ],
      ),
    );
  }
}

class NativeDatabaseCard extends StatelessWidget {
  const NativeDatabaseCard({
    super.key,
    required this.database,
    required this.isAnonymous,
    this.isSingleDatabase = false,
  });

  final NativeDbListItem database;
  final bool isAnonymous;
  final bool isSingleDatabase;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String description = database.description.trim();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: isSingleDatabase
          ? null
          : BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAnonymous
                    ? Colors.white70
                    : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  database.name.isEmpty
                      ? 'Database #${database.id}'
                      : database.name,
                  style: StyleService.toolHeaderTextStyle(isDark),
                ),
              ),
              const SizedBox(width: 10),
              NativeDatabaseBadge(
                text: '${database.columns.length} ${Strings.columns.tr}',
                isAnonymous: isAnonymous,
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              description,
              style: StyleService.toolNormalTextStyle(isDark),
            ),
          ],
          if (database.allowedOperations.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: database.allowedOperations
                  .map(
                    (op) =>
                        NativeDatabaseChip(text: op, isAnonymous: isAnonymous),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
