import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:get/get.dart';

class TaskCapabilityPill extends StatelessWidget {
  const TaskCapabilityPill({
    super.key,
    required this.label,
    required this.active,
    required this.isAnonymous,
    required this.bodyColor,
  });

  final String label;
  final bool active;
  final bool isAnonymous;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final double fontSize = isTablet ? 16.0 : 14.0;
    final PupauThemeData theme = MyStyles.pupauTheme(!Get.isDarkMode);
    final Color activeColor = isAnonymous ? Colors.white : theme.darkBlue;
    final Color inactiveColor = theme.grey.withValues(alpha: 0.5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: active ? activeColor : inactiveColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: active ? activeColor : inactiveColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: active ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
