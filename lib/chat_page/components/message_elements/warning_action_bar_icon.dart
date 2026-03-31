import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class WarningActionBarIcon extends GetView<PupauChatController> {
  const WarningActionBarIcon({
    super.key,
    required this.message,
    required this.isAnonymous,
  });

  final PupauMessage message;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool opened = controller
          .attachmentTrimmingOpenedMessageIds
          .contains(message.id);
      return Tooltip(
        message: Strings.attachmentTrimmingTitle.tr,
        child: InkWell(
          onTap: () =>
              controller.showAttachmentTrimmingModalForMessage(message),
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  color: isAnonymous
                      ? Colors.white
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                  Symbols.warning,
                  size: DeviceService.isTablet ? 24 : 20,
                ),
                if (!opened)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
