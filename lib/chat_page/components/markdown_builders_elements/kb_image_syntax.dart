import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/models/kb_image_model.dart';

/// Turns an ALLOWLISTED `<kb-image id="X"/>` into a `kb-image` markdown
/// element carrying the resolved ref's fields as string attributes. An `id`
/// outside [kbImages] — the model can invent or copy a
/// stray sqid — is dropped silently: no element, no literal tag text, no
/// placeholder. That's the "an id you can't validate gets discarded, not
/// rendered" rule from §5.2, applied at parse time so it can never reach a
/// widget that might fetch it.
///
/// Matches [kbImagePlaceholderRegex], NOT the raw `<kb-image .../>` tag —
/// `TagService.escapeKbImageTags` must run on the text first (`MessageBody`
/// already does this via `TagService.convertTags`). See
/// [kbImagePlaceholderStart]'s doc: a self-closing tag alone on its own line
/// gets swallowed whole by the `markdown` package's HTML-block handling
/// before any `InlineSyntax`, this one included, ever runs.
class KbImageSyntax extends md.InlineSyntax {
  KbImageSyntax(this.kbImages, this.queryId)
    : super(kbImagePlaceholderRegex.pattern);

  final List<KbImageRef> kbImages;
  final String? queryId;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final String id = (match[1] ?? '').trim();
    KbImageRef? ref;
    for (final KbImageRef candidate in kbImages) {
      if (candidate.id == id) {
        ref = candidate;
        break;
      }
    }
    // Outside the allowlist (or a malformed id): consume the tag, add
    // nothing — never falls back to literal text, unlike an unresolved `[n]`.
    if (id.isEmpty || ref == null) return true;

    final md.Element element = md.Element.withTag('kb-image');
    element.attributes['id'] = ref.id;
    if ((queryId ?? '').isNotEmpty) element.attributes['queryId'] = queryId!;
    if ((ref.name ?? '').isNotEmpty) element.attributes['name'] = ref.name!;
    if (ref.pageNumber != null) {
      element.attributes['pageNumber'] = ref.pageNumber.toString();
    }
    if (ref.width != null) element.attributes['width'] = ref.width.toString();
    if (ref.height != null) {
      element.attributes['height'] = ref.height.toString();
    }
    parser.addNode(element);
    return true;
  }
}
