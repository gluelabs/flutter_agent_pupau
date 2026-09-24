import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/shared/kb_image_inline.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Builds the widget for a `kb-image` element ([KbImageSyntax] already
/// resolved and allowlist-checked it — nothing left to validate here beyond
/// having the two required ids).
class KbImageBuilder extends MarkdownElementBuilder {
  KbImageBuilder();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String id = getString(element.attributes['id']);
    final String queryId = getString(element.attributes['queryId']);
    // Can't fetch without both — degrade to nothing, not an error.
    if (id.isEmpty || queryId.isEmpty) {
      return null;
    }

    final int? width = getIntOrNull(element.attributes['width']);
    final int? height = getIntOrNull(element.attributes['height']);
    return KbImageInline(
      embeddingId: id,
      queryId: queryId,
      name: getStringOrNull(element.attributes['name']),
      pageNumber: getIntOrNull(element.attributes['pageNumber']),
      aspectRatio: (width != null && height != null && height != 0)
          ? width / height
          : null,
    );
  }
}
