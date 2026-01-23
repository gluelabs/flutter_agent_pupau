import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/code_container.dart';

class CodeBuilder extends MarkdownElementBuilder {
  CodeBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
          TextStyle? preferredStyle, TextStyle? parentStyle) =>
      CodeContainer(element: element);
}
