import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class SearchExternalButton extends GetView<ChatController> {
  const SearchExternalButton(
      {super.key, required this.message});

  final PupauMessage message;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      bool isLastMessage = message ==
          controller.messages.firstOrNull; //messages list is reversed
      bool visible = controller.externalSearchVisible.value &&
          controller.assistant.value?.replyMode == ReplyMode.hybrid &&
          !message.isExternalSearch &&
          isLastMessage;
      bool isAnonymous = controller.isAnonymous;
      return Visibility(
        visible: visible,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 2),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () =>
                  controller.sendMessage(controller.messages[1].answer, true),
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
                child: Text(Strings.searchExternalSource.tr,
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
