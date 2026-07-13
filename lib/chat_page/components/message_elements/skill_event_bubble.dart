import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

/// Compact, non-expandable row for SSE `SKILL_LOADED` / `SKILL_UNLOADED` events.
class SkillEventBubble extends GetView<PupauChatController> {
  const SkillEventBubble({super.key, required this.detail});

  final SkillEventDetail detail;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final String label = detail.isUnload
        ? Strings.skillEventUnloaded.tr
        : Strings.skillEventLoaded.tr;
    final bool isTablet = DeviceService.isTablet;
    final bool isAnonymous = controller.isAnonymous;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        padding: const EdgeInsets.only(left: 6, right:  15, top: 8, bottom: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Opacity(
          opacity: detail.isUnload ? 0.7 : 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Constants.skillIcon, size: isTablet ? 20 : 18, color: isAnonymous ? Colors.white :  MyStyles.pupauTheme(!Get.isDarkMode).primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$label: ${detail.info.name}',
                  style: TextStyle(fontSize: isTablet ? 14 : 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
