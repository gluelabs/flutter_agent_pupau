import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class ConversationStarterChip extends GetView<ChatController> {
  const ConversationStarterChip({super.key, required this.starter});

  final String starter;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    Color darkBlue = isAnonymous
        ? Colors.black
        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue;
    Color white = isAnonymous
        ? Colors.white
        : MyStyles.pupauTheme(!Get.isDarkMode).white;

    return Material(
      color: white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => controller.sendMessage(starter, false),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isAnonymous ? Colors.grey : darkBlue),
          ),
          child: Text(
            starter,
            style: TextStyle(
              fontSize: isTablet ? 17 : 15,
              fontWeight: FontWeight.w600,
              color: darkBlue,
            ),
          ),
        ),
      ),
    );
  }
}
