import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class RetrySendAudioButton extends GetView<PupauChatController> {
  const RetrySendAudioButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => controller.retryLastFailedAudioMessage(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAnonymous
                      ? AnonymousThemeColors.accent
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                ),
              ),
              child: Text(
                Strings.retry.tr,
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  fontWeight: FontWeight.w600,
                  color: isAnonymous
                      ? AnonymousThemeColors.accent
                      : MyStyles.pupauTheme(!Get.isDarkMode).accent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
