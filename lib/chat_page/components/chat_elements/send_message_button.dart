import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class SendMessageButton extends GetView<ChatController> {
  const SendMessageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool stopIsActive = controller.stopIsActive();
      bool sendIsActive = controller.sendIsActive();
      bool isAnonymous = controller.isAnonymous;
      return IconButton(
          onPressed: stopIsActive
              ? () => controller.sendCancel()
              : sendIsActive
                  ? () => controller.sendMessage(
                      controller.inputMessageController.getText, false)
                  : null,
          tooltip: stopIsActive ? Strings.stop.tr : Strings.send.tr,
          icon: Icon(stopIsActive ? Symbols.stop : Symbols.send,
              size: 26,
              color: isAnonymous
                  ? Colors.black
                  : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue));
    });
  }
}
