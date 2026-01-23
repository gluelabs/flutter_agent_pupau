import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/prompt_option_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class PromptOptionButton extends GetView<ChatController> {
  const PromptOptionButton({
    super.key,
    required this.option,
  });

  final PromptOption option;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      // ignore: invalid_use_of_protected_member
      bool isActive = controller.messages.value.first.id == option.messageId;
      bool isAnonymous = controller.isAnonymous;
      return AbsorbPointer(
        absorbing: !isActive,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.5,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => controller.sendMessage(option.prompt, false),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: isAnonymous
                          ? AnonymousThemeColors.accent
                          : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                ),
                child: Text(option.text,
                    style: TextStyle(
                        fontSize: isTablet ? 17 : 15,
                        fontWeight: FontWeight.w600,
                        color: isAnonymous
                            ? AnonymousThemeColors.accent
                            : MyStyles.pupauTheme(!Get.isDarkMode).accent)),
              ),
            ),
          ),
        ),
      );
    });
  }
}
