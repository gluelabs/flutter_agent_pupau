import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class TextToSpeachIcon extends GetView<ChatController> {
  const TextToSpeachIcon(
      {super.key, required this.message, this.isAnonymous = false});

  final PupauMessage message;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Align(
      alignment: Alignment.centerRight,
      child: Obx(() {
        bool isNarrating = controller.messages
                .firstWhereOrNull((PupauMessage msg) =>
                    msg.id == message.id && msg.isMessageFromAssistant)
                ?.isNarrating ??
            false;
        return Tooltip(
          message: isNarrating ? Strings.stop.tr : Strings.read.tr,
          child: InkWell(
            onTap: () => isNarrating
                ? controller.ttsService.stopReadingMessage(message, controller)
                : controller.ttsService
                    .startReading(message, controller.messages, controller),
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                color: isAnonymous
                    ? Colors.white
                    : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                isNarrating ? Symbols.volume_off : Symbols.volume_up,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        );
      }),
    );
  }
}
