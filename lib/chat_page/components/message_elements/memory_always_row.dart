import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_badge.dart';
import 'package:flutter_agent_pupau/models/memory_always_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:get/get.dart';

class MemoryAlwaysRow extends StatelessWidget {
  const MemoryAlwaysRow({super.key, required this.memory});
  final MemoryAlways memory;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final PupauThemeData theme = MyStyles.pupauTheme(!Get.isDarkMode);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBadge(
            text: Strings.always.tr,
            background: theme.green,
            foreground: theme.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              memory.content,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w400,
                color: MyStyles.getTextTheme(
                  isLightTheme: !Get.isDarkMode,
                ).bodyMedium?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
