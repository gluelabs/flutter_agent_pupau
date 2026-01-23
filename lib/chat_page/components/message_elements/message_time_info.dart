import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageTimeInfo extends GetView<ChatController> {
  const MessageTimeInfo({
    super.key,
    required this.localDate,
    required this.isAssistant,
  });

  final DateTime? localDate;
  final bool isAssistant;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Visibility(
      visible: localDate != null,
      child: Padding(
        padding: isAssistant
            ? const EdgeInsets.symmetric(horizontal: 8)
            : const EdgeInsets.only(top: 6),
        child: Text(
          DateFormat('HH:mm').format(localDate ?? DateTime.now()),
          style: TextStyle(
            color: isAssistant
                ? isAnonymous
                      ? AnonymousThemeColors.assistantText
                      : Get.isDarkMode
                      ? null
                      : MyStyles.pupauTheme(!Get.isDarkMode).grey
                : isAnonymous
                ? AnonymousThemeColors.userText
                : MyStyles.pupauTheme(!Get.isDarkMode).white,
            fontSize: isTablet ? 14 : 12,
          ),
        ),
      ),
    );
  }
}
