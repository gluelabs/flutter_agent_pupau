import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class SpreadsheetErrorBox extends StatelessWidget {
  const SpreadsheetErrorBox({
    super.key,
    required this.message,
    required this.isAnonymous,
  });

  final String message;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final String safeMessage =
        message.trim().isEmpty ? Strings.error.tr : message.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Symbols.error, size: 20, color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${Strings.error.tr}: $safeMessage',
              style: StyleService.toolNormalTextStyle(isDark),
            ),
          ),
        ],
      ),
    );
  }
}
