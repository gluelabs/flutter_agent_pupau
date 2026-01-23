import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ThinkingTagContainer extends GetView<ChatController> {
  const ThinkingTagContainer({super.key, required this.thinkingMessage});

  final String thinkingMessage;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    String blankSpace = "‎ ‎  ";
    String formattedMessage = thinkingMessage.replaceAll('<line-break>', '\n');
    bool isAnonymous = controller.isAnonymous;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isAnonymous
              ? AnonymousThemeColors.background
              : MyStyles.pupauTheme(
                  !Get.isDarkMode,
                ).grey.withValues(alpha: Get.isDarkMode ? 1 : 0.1),
        ),
        child: Stack(
          children: [
            Icon(
              Symbols.lightbulb,
              size: isTablet ? 24 : 20,
              color: isAnonymous ? AnonymousThemeColors.assistantText : null,
            ),
            MarkdownBody(
              data: "$blankSpace \t $formattedMessage",
              selectable: true,
              styleSheet:
                  MarkdownStyleSheet.fromTheme(
                    ThemeData(
                      brightness: Get.isDarkMode
                          ? Brightness.dark
                          : Brightness.light,
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          fontSize: isTablet ? 17 : 15,
                          color: isAnonymous
                              ? AnonymousThemeColors.assistantText
                              : null,
                        ),
                      ),
                    ),
                  ).copyWith(
                    blockquoteDecoration: BoxDecoration(
                      color: MyStyles.pupauTheme(
                        !Get.isDarkMode,
                      ).lilacHover.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    blockquotePadding: const EdgeInsets.all(12),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
