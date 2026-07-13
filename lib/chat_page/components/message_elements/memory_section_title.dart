import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class MemorySectionTitle extends StatelessWidget {
  const MemorySectionTitle({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
          color: MyStyles.getTextTheme(
            isLightTheme: !Get.isDarkMode,
          ).bodyMedium?.color,
        ),
      ),
    );
  }
}
