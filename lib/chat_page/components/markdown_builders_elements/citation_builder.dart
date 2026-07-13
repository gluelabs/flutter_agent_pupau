import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/citation_chip.dart';

class CitationBuilder extends MarkdownElementBuilder {
  CitationBuilder();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final CitationElementData? data = CitationElementData.fromAttributes(
      element.attributes,
    );
    if (data == null) return null;
    return CitationChip(data: data);
  }
}
