import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/google_maps_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

import 'google_map_container.dart';

class GoogleMapBuilder extends MarkdownElementBuilder {
  GoogleMapBuilder();

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    GoogleMapData googleMapData =
        TagService.extractMapInfo(element.attributes['google-map-data'] ?? '');
    return GoogleMapContainer(googleMapData: googleMapData);
  }
}
