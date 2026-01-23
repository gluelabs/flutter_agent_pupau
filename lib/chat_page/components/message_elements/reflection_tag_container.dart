import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/prompt_reflection_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ReflectionTagContainer extends GetView<ChatController> {
  const ReflectionTagContainer({super.key, required this.reflection});

  final PromptReflection reflection;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    String blankSpace = "‎ ‎ ‎ ‎ ‎ ‎ ";

    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 14),
      child: Obx(() {
        bool isAnonymous = controller.isAnonymous;
        bool isLastMessage =
            // ignore: invalid_use_of_protected_member
            controller.messages.value.first.id == reflection.messageId;
        return Container(
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
                Symbols.neurology,
                size: isTablet ? 24 : 20,
                color: isAnonymous ? AnonymousThemeColors.assistantText : null,
              ),
              Column(
                children: [
                  MarkdownBody(
                    data: "$blankSpace ${reflection.text}",
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
                            color: MyStyles.pupauTheme(!Get.isDarkMode)
                                .lilacHover
                                .withValues(alpha: Get.isDarkMode ? 0.4 : 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquotePadding: const EdgeInsets.all(12),
                        ),
                  ),
                  if ((!reflection.isPositive) && isLastMessage)
                    Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => controller.sendMessage(
                              controller.messages[1].answer,
                              false,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                Strings.improveResponse.tr,
                                style: TextStyle(
                                  fontSize: isTablet ? 17 : 15,
                                  fontWeight: FontWeight.w500,
                                  color: isAnonymous
                                      ? AnonymousThemeColors.assistantText
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
