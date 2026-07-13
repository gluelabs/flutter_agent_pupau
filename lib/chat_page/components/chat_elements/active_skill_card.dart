import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Single read-only row for one active skill (modal list).
class ActiveSkillCard extends StatelessWidget {
  const ActiveSkillCard({super.key, required this.skill});

  final SkillLoadedInfo skill;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final Color? titleColor = MyStyles.getTextTheme(
      isLightTheme: !Get.isDarkMode,
    ).bodyMedium?.color;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                skill.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: titleColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                '${Strings.skillLoadedBy.tr}: ${skill.loadedBy.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
