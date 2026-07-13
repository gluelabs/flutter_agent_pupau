import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// History badge when [PupauMessage.skillsLoaded] is present (extraInfo).
class SkillsLoadedBadge extends GetView<PupauChatController> {
  const SkillsLoadedBadge({super.key, required this.skills});

  final List<SkillLoadedInfo> skills;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    if (skills.isEmpty) return const SizedBox.shrink();
    final String tooltip = skills.map((SkillLoadedInfo s) => s.name).join('\n');
    final String badgeText = Strings.skillsActiveCount.tr.replaceAll(
      '@count',
      '${skills.length}',
    );
    final bool isTablet = DeviceService.isTablet;
    final bool isAnonymous = controller.isAnonymous;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Tooltip(
        message: tooltip,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Constants.skillIcon,
              size: isTablet ? 18 : 16,
              color: isAnonymous
                  ? Colors.white
                  : MyStyles.pupauTheme(!Get.isDarkMode).primary,
            ),
            const SizedBox(width: 6),
            Text(badgeText, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
