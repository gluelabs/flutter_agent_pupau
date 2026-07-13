import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class SendMessageButton extends GetView<PupauChatController> {
  const SendMessageButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      bool isEnabled =
          !controller.isStreaming.value &&
          !controller.isStopping.value &&
          controller.inputMessage.value.trim() != "";
      return Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: IconButton(
          onPressed: isEnabled
              ? () => controller.sendMessage(
                  controller.inputMessageController.getText,
                  false,
                )
              : null,
          tooltip: Strings.send.tr,
          icon: Icon(
            Symbols.send,
            size: 26,
            color: isAnonymous
                ? Colors.black
                : MyStyles.pupauTheme(!Get.isDarkMode).primary,
          ),
        ),
      );
    });
  }
}
