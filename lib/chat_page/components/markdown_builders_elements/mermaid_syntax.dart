import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/tag_service.dart';

class MermaidSyntax extends md.InlineSyntax {
  MermaidSyntax() : super(TagService.mermaidRegex.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.withTag('mermaid-container');
    element.attributes['mermaid-code'] = match.group(0) ?? '';
    parser.addNode(element);
    return true;
  }
}

/*

class MermaidBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => TagService.mermaidRegex;

  const MermaidBlockSyntax();

  @override
  md.Node parse(md.BlockParser parser) {
    var content = parser.current.content;
    var match = pattern.firstMatch(content);
    if (match == null) {
      parser.advance();
      return md.Element.empty('empty');
    }
    var element = md.Element.withTag('mermaid-container');
    element.attributes['mermaid-code'] = match.group(0) ?? '';
    parser.advance();
    return element;
  }

  @override
  bool canParse(md.BlockParser parser) {
    return pattern.hasMatch(parser.current.content);
  }
}
*/
