import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class RelatedSearchButton extends GetView<ChatController> {
  const RelatedSearchButton({
    super.key,
    required this.prompt,
  });

  final String prompt;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => controller.sendMessage(prompt, false),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: isAnonymous
                      ? AnonymousThemeColors.accent
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
            ),
            child: Text(prompt,
                style: TextStyle(
                    fontSize: isTablet ? 15 : 13.5,
                    fontWeight: FontWeight.w600,
                    color: isAnonymous
                        ? AnonymousThemeColors.accent
                        : MyStyles.pupauTheme(!Get.isDarkMode).accent)),
          ),
        ),
      );
  }
}
