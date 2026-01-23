import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class AssistantChip extends GetView<ChatController> {
  const AssistantChip(
      {super.key, required this.assistant, this.isAnonymous = false});
  final Assistant assistant;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    Color darkBlue = isAnonymous
        ? Colors.black
        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue;
    Color white =
        isAnonymous ? Colors.white : MyStyles.pupauTheme(!Get.isDarkMode).white;
    return Container(
      height: isTablet ? 42 : 38,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12.5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isAnonymous ? Colors.grey : white),
          color: darkBlue),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AssistantAvatar(
              assistantId: assistant.id,
              imageUuid: assistant.imageUuid,
              isMarketplaceUrl: assistant.type == AssistantType.marketplace,
              radius: 11,
              format: ImageFormat.high),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              assistant.name,
              style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  fontWeight: FontWeight.w600,
                  color: white),
            ),
          ),
          InkWell(
              onTap: () => controller.removeTaggedAssistant(assistant),
              child: Icon(Icons.close, color: white, size: 22)),
        ],
      ),
    );
  }
}
