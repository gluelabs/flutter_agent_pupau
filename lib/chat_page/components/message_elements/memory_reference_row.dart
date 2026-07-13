import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_badge.dart';
import 'package:flutter_agent_pupau/models/memory_reference_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:get/get.dart';

class MemoryReferenceRow extends StatelessWidget {
  const MemoryReferenceRow({super.key, required this.memory});
  final MemoryReference memory;

  String _sourceLabelKey(MemoryReferenceSource source) {
    switch (source) {
      case MemoryReferenceSource.user:
        return Strings.memorySourceUser;
      case MemoryReferenceSource.agent:
        return Strings.agent;
      case MemoryReferenceSource.system:
        return Strings.memorySourceSystem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final PupauThemeData theme = MyStyles.pupauTheme(!Get.isDarkMode);
    final double clamped = memory.similarity < 0
        ? 0
        : (memory.similarity > 1 ? 1 : memory.similarity);
    final int pct = (clamped * 100).round();
    final String category = (memory.category ?? '').trim();
    final MemoryReferenceSource source = memory.source;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                    color: MyStyles.getTextTheme(
                      isLightTheme: !Get.isDarkMode,
                    ).bodyMedium?.color,
                  ),
                ),
              ),
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
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 6,
                backgroundColor: theme.primary.withValues(alpha: 0.15),
                color: theme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (category.isNotEmpty)
                  CustomBadge(
                    text: category,
                    background: theme.grey.withValues(
                      alpha: Get.isDarkMode ? 1 : 0.1,
                    ),
                    foreground: MyStyles.getTextTheme(
                      isLightTheme: !Get.isDarkMode,
                    ).bodyMedium!.color!,
                  ),
                CustomBadge(
                  text: _sourceLabelKey(source).tr,
                  background: theme.grey.withValues(
                    alpha: Get.isDarkMode ? 1 : 0.1,
                  ),
                  foreground: MyStyles.getTextTheme(
                    isLightTheme: !Get.isDarkMode,
                  ).bodyMedium!.color!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
