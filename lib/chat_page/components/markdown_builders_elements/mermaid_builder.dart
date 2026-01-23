import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'mermaid_container.dart';

class MermaidBuilder extends MarkdownElementBuilder {
  MermaidBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    String mermaidCode = element.attributes['mermaid-code'] ?? '';
    return MermaidContainer(mermaidCode: mermaidCode);
  }
}
