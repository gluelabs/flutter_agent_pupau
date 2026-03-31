import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class TaskInfoChip extends StatelessWidget {
  const TaskInfoChip({
    super.key,
    required this.value,
    required this.isAnonymous,
  });

  final String value;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final fontSize = isTablet ? 15.0 : 13.0;
    final Color? textColor = isAnonymous
        ? Colors.white
        : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
            .bodyMedium
            ?.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: textColor?.withValues(alpha: 0.06) ?? Colors.transparent,
        border: Border.all(
          color: MyStyles.pupauTheme(!Get.isDarkMode).lilacHover,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor?.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
