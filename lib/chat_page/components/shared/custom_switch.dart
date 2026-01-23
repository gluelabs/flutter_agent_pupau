import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class CustomSwitch extends StatelessWidget {
  const CustomSwitch(
      {super.key,
      required this.isActive,
      required this.onChanged,
      this.isDoubleOption = false});

  final bool isActive;
  final bool isDoubleOption;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: isActive,
      onChanged: onChanged,
      activeThumbColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      inactiveThumbColor:
          isDoubleOption ? MyStyles.pupauTheme(!Get.isDarkMode).white : null,
      trackOutlineColor: isDoubleOption
          ? WidgetStateProperty.all<Color>(
              MyStyles.pupauTheme(!Get.isDarkMode).accent)
          : null,
      activeTrackColor: MyStyles.pupauTheme(!Get.isDarkMode).accent,
      inactiveTrackColor: isDoubleOption
          ? MyStyles.pupauTheme(!Get.isDarkMode).accent
          : !Get.isDarkMode
              ? MyStyles.pupauTheme(!Get.isDarkMode).grey.withValues(alpha: 0.5)
              : null,
    );
  }
}
