import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_time_info.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class AudioConvertingInfo extends StatelessWidget {
  const AudioConvertingInfo({
    super.key,
    required this.isAnonymous,
    required this.createdAt,
  });

  final bool isAnonymous;
  final DateTime? createdAt;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              Symbols.mic,
              size: isTablet ? 24 : 20,
              color: isAnonymous
                  ? AnonymousThemeColors.userText
                  : MyStyles.pupauTheme(!Get.isDarkMode).white,
            ),
            const SizedBox(width: 8),
            Text(
              Strings.convertingAudio.tr,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isAnonymous
                    ? AnonymousThemeColors.userText
                    : MyStyles.pupauTheme(!Get.isDarkMode).white,
              ),
            ),
          ],
        ),
        MessageTimeInfo(localDate: createdAt?.toLocal(), isAssistant: false),
      ],
    );
  }
}
