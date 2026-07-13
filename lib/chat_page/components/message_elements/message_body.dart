import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/code_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/download_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/download_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/google_map_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/google_map_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/link_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/mermaid_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/mermaid_syntax.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_markdown_scope.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/selection_transformer.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageBody extends StatelessWidget {
  const MessageBody({
    super.key,
    required this.messageId,
    required this.message,
    required this.isFromAssistant,
    required this.isAnonymous,
    this.grounding,
    this.wrapInFlexible = true,
    this.wrapWithSelectionArea = true,
  });

  final String messageId;
  final String message;
  final bool isFromAssistant;
  final bool isAnonymous;
  final GroundingInfo? grounding;

  /// When false, returns the markdown subtree only (for embedding inside another
  /// [Flexible] / expand wrapper, e.g. user collapsible column in [MessageContent]).
  final bool wrapInFlexible;

  /// When false, skips [SelectionArea] so parent taps (e.g. expand bubble) are not
  /// delayed or blocked by selection gestures on the markdown text.
  final bool wrapWithSelectionArea;

  MarkdownStyleSheet _markdownStyleSheet(bool isTablet) {
    return MarkdownStyleSheet.fromTheme(
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
                : MyStyles.getTextTheme(isLightTheme: true).bodyMedium?.color,
          ),
        ),
      ),
    ).copyWith(
      blockquoteDecoration: BoxDecoration(
        color: MyStyles.pupauTheme(
          !Get.isDarkMode,
        ).primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      blockquotePadding: const EdgeInsets.all(12),
    );
  }

  Widget _markdownScope(String convertedForMarkdown) {
    return MessageMarkdownScope(
      messageId: messageId,
      child: MarkdownBody(
        data: StringService.fixMarkdownNewLines(convertedForMarkdown),
        selectable: false,
        onTapLink: (dynamic link, String? href, String? title) =>
            DeviceService.openLink(
              link is String ? link : link.toString(),
              href: href,
              title: title ?? '',
            ),
        inlineSyntaxes: isFromAssistant
            ? [
                GoogleMapSyntax(),
                MermaidSyntax(),
                DownloadSyntax(),
                CitationSyntax(grounding),
              ]
            : [],
        builders: isFromAssistant
            ? {
                'google-map': GoogleMapBuilder(),
                'mermaid-container': MermaidBuilder(),
                'download-container': DownloadBuilder(),
                'citation-chip': CitationBuilder(),
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
        styleSheet: _markdownStyleSheet(DeviceService.isTablet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String convertedMessage = TagService.convertTags(message);
    final Widget markdownCore = _markdownScope(convertedMessage);
    final Widget wrappedMarkdown = wrapWithSelectionArea
        ? SelectionArea(
            child: SelectionTransformer.separated(
              separator: "\n\n",
              child: markdownCore,
            ),
          )
        : markdownCore;
    return wrapInFlexible ? Flexible(child: wrappedMarkdown) : wrappedMarkdown;
  }
}
