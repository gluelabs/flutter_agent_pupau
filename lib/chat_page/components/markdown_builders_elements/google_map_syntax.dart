import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/tag_service.dart';

class GoogleMapSyntax extends md.InlineSyntax {
  GoogleMapSyntax() : super(TagService.mapRegex.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.withTag('google-map');
    element.attributes['google-map-data'] = match.group(0) ?? '';
    parser.addNode(element);
    return true;
  }
}
