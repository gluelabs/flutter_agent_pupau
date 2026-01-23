import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/download_container.dart';

class DownloadBuilder extends MarkdownElementBuilder {
  DownloadBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    String format = element.attributes['download-format'] ?? '';
    String id = element.attributes['download-id'] ?? '';
    String text = element.attributes['download-text'] ?? '';
    return DownloadContainer(
      format: format,
      id: id,
      text: text,
    );
  }
}
