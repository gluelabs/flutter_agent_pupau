import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/thinking_tag_container.dart';

class ThinkingBuilder extends MarkdownElementBuilder {
  ThinkingBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    String thinkingData = element.attributes['thinking-data'] ?? '';
    return ThinkingTagContainer(thinkingMessage: thinkingData);
  }
}
