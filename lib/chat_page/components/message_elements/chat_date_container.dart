import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/localization_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ChatDateContainer extends GetView<ChatController> {
  const ChatDateContainer({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: Text(
          formatDate(
            date,
            [d, " ", MM, " ", yyyy],
            locale: LocalizationService.getDateLocale(controller.pupauConfig != null ? LocalizationService.getLanguageFromConfig(controller.pupauConfig!) : Language.english),
          ),
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: isAnonymous
                ? AnonymousThemeColors.assistantText
                : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          ),
        ),
      ),
    );
  }
}
