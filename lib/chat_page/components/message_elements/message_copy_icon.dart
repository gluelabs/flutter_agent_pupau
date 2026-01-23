import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageCopyIcon extends GetView<ChatController> {
  const MessageCopyIcon(
      {super.key, required this.message, this.isAnonymous = false});

  final PupauMessage message;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Align(
        alignment: Alignment.centerRight,
        child: Tooltip(
          message: Strings.copy.tr,
          child: InkWell(
            onTap: () {
              Clipboard.setData(ClipboardData(
                  text: ConversationService.copyMessageWithoutTags(message.answer)));
              showFeedbackSnackbar(
                  Strings.copiedClipboard.tr, Symbols.content_copy,
                  isInfo: true);
            },
            borderRadius: BorderRadius.circular(100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                color: isAnonymous
                    ? Colors.white
                    : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                Symbols.content_copy,
                size: isTablet ? 24 : 20,
              ),
            ),
          ),
        ));
  }
}
