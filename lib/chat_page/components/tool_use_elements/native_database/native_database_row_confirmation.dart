import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/native_database/native_database_shared_widgets.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_native_database_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:get/get.dart';

class NativeDatabaseRowConfirmationCard extends StatelessWidget {
  const NativeDatabaseRowConfirmationCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.row,
    required this.isAnonymous,
    required this.databaseName,
    required this.scope,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> row;
  final bool isAnonymous;
  final String? databaseName;
  final NativeDbScope scope;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final List<MapEntry<String, dynamic>> preview = row.entries.toList();
    final bool hasDatabaseName = (databaseName ?? '').trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasDatabaseName) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    databaseName!.trim(),
                    style: StyleService.toolHeaderTextStyle(isDark),
                  ),
                ),
                const SizedBox(width: 10),
                NativeDatabaseScopeBadge(
                  scope: scope,
                  isAnonymous: isAnonymous,
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: StyleService.toolHeaderTextStyle(isDark),
                ),
              ),
              if (!hasDatabaseName) ...[
                const SizedBox(width: 10),
                NativeDatabaseScopeBadge(
                  scope: scope,
                  isAnonymous: isAnonymous,
                ),
              ],
            ],
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
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
