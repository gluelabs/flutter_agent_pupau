import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as m;
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/marketplace_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageSenderInfo extends GetView<ChatController> {
  const MessageSenderInfo({super.key, required this.assistant});

  final Assistant? assistant;

  @override
  Widget build(BuildContext context) {
    bool isMarketplace = assistant?.type == AssistantType.marketplace;
    bool isTablet = DeviceService.isTablet;
    double fontSize = isTablet ? 17 : 15;
    return Obx(() {
      bool isAnonymous = controller.isAnonymous;
      bool isCurrentAssistant = assistant?.id == controller.assistant.value?.id;
      return Visibility(
        visible: !isCurrentAssistant,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: IntrinsicWidth(
            child: Row(
              children: [
                AssistantAvatar(
                  assistantId: assistant?.id ?? "",
                  imageUuid: assistant?.imageUuid ?? "",
                  radius: 14,
                  format: ImageFormat.low,
                  isMarketplaceUrl: isMarketplace,
                ),
                SizedBox(width: 10),
                Flexible(
                  child: m.Text(assistant?.name ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: fontSize,
                          color: Get.isDarkMode || isAnonymous
                              ? Colors.white
                              : MyStyles.pupauTheme(!Get.isDarkMode).accent)),
                ),
                if (isMarketplace)
                  Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: MarketplaceIcon(
                          color: isAnonymous ? Colors.white : null))
              ],
            ),
          ),
        ),
      );
    });
  }
}
