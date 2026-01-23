import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class LoadingTag extends GetView<ChatController> {
  const LoadingTag({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 6),
          child: SizedBox(
            height: 30,
            child: Row(
              children: [
                Text(
                  controller.loadingMessage.value.message,
                  style: TextStyle(
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w700,
                    color: isAnonymous
                        ? AnonymousThemeColors.assistantText
                        : null,
                  ),
                ),
                SizedBox(width: 8),
                JumpingDots(
                  radius: 3,
                  verticalOffset: -10,
                  innerPadding: 3.5,
                  numberOfDots: 3,
                  color: isAnonymous
                      ? AnonymousThemeColors.assistantText
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                  animationDuration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
