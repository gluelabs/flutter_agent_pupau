import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/selection_transformer.dart';

class CustomSelectableText extends StatelessWidget {
  const CustomSelectableText({
    super.key,
    required this.text,
    this.openLinks = true,
    this.isAnonymous = false,
    this.textStyle,
  });

  final String text;
  final bool openLinks;
  final bool isAnonymous;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;

    return SelectionArea(
      child: SelectionTransformer.separated(
        separator: "\n\n",
        child: MarkdownBody(
          data: text,
          selectable: false,
          onTapLink: (link, href, title) => openLinks
              ? DeviceService.openLink(link, href: href, title: title)
              : null,
          styleSheet:
              MarkdownStyleSheet.fromTheme(
                ThemeData(
                  brightness: Get.isDarkMode || isAnonymous
                      ? Brightness.dark
                      : Brightness.light,
                  textTheme: TextTheme(
                    bodyMedium:
                        textStyle ??
                        TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: isAnonymous
                              ? AnonymousThemeColors.assistantText
                              : MyStyles.getTextTheme(
                                  isLightTheme: !Get.isDarkMode,
                                ).bodyMedium?.color,
                        ),
                  ),
                ),
              ).copyWith(
                a: openLinks
                    ? TextStyle(
                        color: MyStyles.pupauTheme(!Get.isDarkMode).blue,
                        fontWeight: FontWeight.w500,
                      )
                    : TextStyle(
                        color: MyStyles.getTextTheme(
                          isLightTheme: !Get.isDarkMode,
                        ).bodyMedium?.color,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                blockquoteDecoration: BoxDecoration(
                  color: MyStyles.pupauTheme(
                    !Get.isDarkMode,
                  ).lilacHover.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                blockquotePadding: const EdgeInsets.all(12),
              ),
        ),
      ),
    );
  }
}
