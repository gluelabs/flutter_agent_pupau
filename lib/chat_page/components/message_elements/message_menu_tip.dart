import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageMenuTip extends GetView<ChatController> {
  const MessageMenuTip({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Opacity(
            opacity: 0.8,
            child: Row(
              children: [
                Icon(
                  Symbols.touch_double,
                  size: isTablet ? 22 : 20,
                  color: controller.isAnonymous
                      ? AnonymousThemeColors.assistantText
                      : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                          .bodyMedium
                          ?.color,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    Strings.doubleTapToShowMoreOptions.tr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                        color: controller.isAnonymous
                            ? AnonymousThemeColors.assistantText
                            : MyStyles.getTextTheme(
                                    isLightTheme: !Get.isDarkMode)
                                .bodyMedium
                                ?.color),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
