import 'package:flutter/material.dart';
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
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final Map<String, dynamic> row;
  final bool isAnonymous;
  final String? databaseName;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final List<MapEntry<String, dynamic>> preview =
        row.entries.toList();

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
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: StyleService.toolHeaderTextStyle(isDark),
                ),
              ),
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

