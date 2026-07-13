import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class VoiceRecordingButton extends GetView<PupauChatController> {
  const VoiceRecordingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      final bool isEnabled = !controller.isStreaming.value;
      return Opacity(
        opacity: isEnabled ? 1.0 : 0.5,
        child: IconButton(
          icon: Icon(
            Symbols.mic,
            size: 26,
            color: isAnonymous
                ? Colors.black
                : MyStyles.pupauTheme(!Get.isDarkMode).primary,
          ),
          onPressed: isEnabled ? () => controller.startRecording() : null,
          tooltip: Strings.recordAudio.tr,
        ),
      );
    });
  }
}
