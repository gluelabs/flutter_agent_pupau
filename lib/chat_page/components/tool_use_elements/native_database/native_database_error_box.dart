import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class NativeDatabaseErrorBox extends StatelessWidget {
  const NativeDatabaseErrorBox({
    super.key,
    required this.message,
    required this.isAnonymous,
    this.databaseName,
  });

  final String message;
  final bool isAnonymous;
  final String? databaseName;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String safeMessage =
        message.trim().isEmpty ? Strings.error.tr : message.trim();
    final Color border = MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((databaseName ?? '').trim().isNotEmpty) ...[
            Text(
              databaseName!.trim(),
              style: StyleService.toolHeaderTextStyle(isDark),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Symbols.error,
                color: border,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${Strings.error.tr}: $safeMessage',
                  style: StyleService.toolNormalTextStyle(isDark),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

