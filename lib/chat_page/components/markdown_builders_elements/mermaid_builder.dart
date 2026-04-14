import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_markdown_scope.dart';
import 'mermaid_container.dart';

class MermaidBuilder extends MarkdownElementBuilder {
  MermaidBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    String mermaidCode = element.attributes['mermaid-code'] ?? '';
    final String? messageId = MessageMarkdownScope.maybeOf(context)?.messageId;
    final String cacheKey = messageId != null && messageId.isNotEmpty
        ? '${messageId}_${mermaidCode.hashCode}'
        : 'm_${mermaidCode.hashCode}';
    return MermaidContainer(
      key: ValueKey(cacheKey),
      cacheKey: cacheKey,
      mermaidCode: mermaidCode,
    );
  }
}
