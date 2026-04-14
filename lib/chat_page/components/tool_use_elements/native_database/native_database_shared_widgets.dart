import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class NativeDatabaseBadge extends StatelessWidget {
  const NativeDatabaseBadge({
    super.key,
    required this.text,
    required this.isAnonymous,
  });

  final String text;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color border = isAnonymous
        ? Colors.white70
        : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: StyleService.toolNormalTextStyle(isDark),
      ),
    );
  }
}

class NativeDatabaseChip extends StatelessWidget {
  const NativeDatabaseChip({
    super.key,
    required this.text,
    required this.isAnonymous,
  });

  final String text;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color border = isAnonymous
        ? Colors.white70
        : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border.withValues(alpha: 0.7)),
      ),
      child: Text(
        text,
        style: StyleService.toolNormalTextStyle(isDark),
      ),
    );
  }
}

