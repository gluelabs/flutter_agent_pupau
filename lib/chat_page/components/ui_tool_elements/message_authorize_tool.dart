import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageAuthorizeTool extends GetView<ChatController> {
  const MessageAuthorizeTool({super.key, required this.message});

  final UiToolMessage message;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 18),
          child: Row(
            children: [
              Icon(
                Symbols.check_circle,
                size: isTablet ? 26 : 24,
                color: isAnonymous
                    ? Colors.white
                    : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.data.message,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Get.isDarkMode || isAnonymous
                        ? Colors.white
                        : MyStyles.getTextTheme(
                                isLightTheme: !Get.isDarkMode,
                              ).bodyMedium?.color ??
                              Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Wrap(
          children: [
            CustomButton(
              text: Strings.undo.tr,
              isWarning: true,
              onPressed: () => controller.hideUiToolBubble(message.id),
            ),
            const SizedBox(width: 10),
            CustomButton(
              text: Strings.confirm.tr,
              onPressed: () {
                controller.hideUiToolBubble(message.id);
                controller.sendUiToolApproval(message.id);
              },
            ),
          ],
        ),
      ],
    );
  }
}
