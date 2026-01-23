import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/code_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/download_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/download_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/google_map_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/google_map_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/link_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/mermaid_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/mermaid_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/thinking_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/thinking_syntax_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/selection_transformer.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageBody extends StatelessWidget {
  const MessageBody({
    super.key,
    required this.message,
    required this.isFromAssistant,
    required this.isAnonymous,
  });

  final String message;
  final bool isFromAssistant;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    String convertedMessage = TagService.convertTags(message);
    bool isTablet = DeviceService.isTablet;
    return Flexible(
      child: SelectionArea(
        child: SelectionTransformer.separated(
          separator: "\n\n",
          child: MarkdownBody(
            data: StringService.fixMarkdownNewLines(convertedMessage),
            selectable: false,
            onTapLink: (link, href, title) =>
                DeviceService.openLink(link, href: href, title: title),
            inlineSyntaxes: isFromAssistant
                ? [
                    GoogleMapSyntax(),
                    MermaidSyntax(),
                    ThinkingSyntax(),
                    DownloadSyntax(),
                  ]
                : [],
            builders: isFromAssistant
                ? {
                    'google-map': GoogleMapBuilder(),
                    'mermaid-container': MermaidBuilder(),
                    'thinking-container': ThinkingBuilder(),
                    'download-container': DownloadBuilder(),
                    'code': CodeBuilder(),
                    'pre': CodeBuilder(),
                    'a': LinkBuilder(
                      isFromAssistant: isFromAssistant,
                      isAnonymous: isAnonymous,
                    ),
                  }
                : {
                    'code': CodeBuilder(),
                    'pre': CodeBuilder(),
                    'a': LinkBuilder(
                      isFromAssistant: isFromAssistant,
                      isAnonymous: isAnonymous,
                    ),
                  },
            styleSheet:
                MarkdownStyleSheet.fromTheme(
                  ThemeData(
                    brightness: Get.isDarkMode || isAnonymous
                        ? Brightness.dark
                        : Brightness.light,
                    textTheme: TextTheme(
                      bodyMedium: TextStyle(
                        fontSize: isTablet ? 17 : 15,
                        color: isFromAssistant
                            ? isAnonymous
                                  ? AnonymousThemeColors.assistantText
                                  : null
                            : isAnonymous
                            ? AnonymousThemeColors.userText
                            : MyStyles.pupauTheme(!Get.isDarkMode).white,
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
        ),
      ),
    );
  }
}
