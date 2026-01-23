import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class DocumentToolDownload extends StatelessWidget {
  const DocumentToolDownload({
    super.key,
    required this.document,
    required this.isAnonymous,
  });

  final DocumentData document;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return MarkdownBody(
      data:
          " [${Strings.download.tr} ${document.fileName}](${document.exportUrl})",
      onTapLink: (link, href, title) =>
          DeviceService.openLink(link, href: href, title: title),
      styleSheet:
          MarkdownStyleSheet.fromTheme(
            ThemeData(
              brightness: Get.isDarkMode || isAnonymous
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
            a: TextStyle(
              color: MyStyles.pupauTheme(!Get.isDarkMode).blue,
              fontWeight: FontWeight.w500,
            ),
            blockquoteDecoration: BoxDecoration(
              color: MyStyles.pupauTheme(
                !Get.isDarkMode,
              ).lilacHover.withValues(alpha: Get.isDarkMode ? 0.4 : 1),
              borderRadius: BorderRadius.circular(8),
            ),
            blockquotePadding: const EdgeInsets.all(12),
          ),
    );
  }
}
