import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'native_database_shared_widgets.dart';

class NativeDatabaseCreatedCard extends StatelessWidget {
  const NativeDatabaseCreatedCard({
    super.key,
    required this.database,
    required this.isAnonymous,
  });

  final NativeDbCreatedDatabase database;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color green = MyStyles.pupauTheme(!Get.isDarkMode).green;
    final String name = database.name.trim();
    final String description = database.description.trim();

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.check_circle, color: green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name.isEmpty
                      ? Strings.nativeDbDatabaseCreated.tr
                      : '${Strings.nativeDbDatabaseCreated.tr}: "$name"',
                  style: StyleService.toolHeaderTextStyle(isDark),
                ),
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
          if (database.columns.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${Strings.columns.tr}:',
              style: StyleService.toolCellHeaderTextStyle(isDark),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: database.columns
                  .map(
                    (c) => NativeDatabaseChip(
                      text:
                          '${c.displayName.trim().isNotEmpty ? c.displayName.trim() : c.name} [${c.type}]',
                      isAnonymous: isAnonymous,
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

