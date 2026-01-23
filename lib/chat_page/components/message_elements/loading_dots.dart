import 'package:flutter/material.dart';
import 'package:jumping_dot/jumping_dot.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class LoadingDots extends GetView<ChatController> {
  const LoadingDots({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Obx(() {
          bool isAnonymous = controller.isAnonymous;
          bool isLoadingConversation = controller.isLoadingConversation.value;
          return Padding(
            padding:
                EdgeInsets.only(left: 20, top: isLoadingConversation ? 40 : 6),
            child: SizedBox(
                height: 30,
                child: JumpingDots(
                    radius: 3,
                    verticalOffset: -10,
                    innerPadding: 3.5,
                    numberOfDots: 3,
                    color: isAnonymous
                        ? AnonymousThemeColors.assistantText
                        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                    animationDuration: const Duration(milliseconds: 200))),
          );
        }),
      ],
    );
  }
}
