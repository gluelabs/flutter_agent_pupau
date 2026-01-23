import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/tag_service.dart';

class DownloadSyntax extends md.InlineSyntax {
  DownloadSyntax() : super(TagService.downloadRegex.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.withTag('download-container');
    element.attributes['download-format'] = match[1] ?? '';
    element.attributes['download-id'] = match[2] ?? '';
    element.attributes['download-text'] = match[3] ?? '';
    parser.addNode(element);
    return true;
  }
}
