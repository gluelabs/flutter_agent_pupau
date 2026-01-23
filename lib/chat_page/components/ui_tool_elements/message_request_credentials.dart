import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageRequestCredentials extends GetView<ChatController> {
  const MessageRequestCredentials({
    super.key,
    required this.message,
  });

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
                Icon(Symbols.check_circle,
                    size: isTablet ? 26 : 24,
                    color: isAnonymous
                        ? Colors.white
                        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Strings.identifyToContinue.tr,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: Get.isDarkMode || isAnonymous
                          ? Colors.white
                          : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                                  .bodyMedium
                                  ?.color ??
                              Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(Strings.authRequired.tr),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
                text: Strings.authenticate.tr,
                onPressed: () =>
                    controller.sendUiToolAuth(message.id, message.data.toolId)),
          )
      ],
    );
  }
}
