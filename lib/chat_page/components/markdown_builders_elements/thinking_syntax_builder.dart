import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/tag_service.dart';

class ThinkingSyntax extends md.InlineSyntax {
  ThinkingSyntax() : super(TagService.thinkingRegex.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.withTag('thinking-container');
    element.attributes['thinking-data'] = match[1] ?? match[0] ?? '';
    parser.addNode(element);
    return true;
  }
}
