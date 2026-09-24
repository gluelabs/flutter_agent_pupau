import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Canonical `<kb-image id="X"/>` inline KB image tag — the
/// single source of truth for matching it in streamed/persisted text.
///
/// Mirrors the backend's own regex exactly (`ISseKb`/`extraInfo` producer,
/// see `www/src/modules/queries/utils/kb-image-tags.util.ts`). `id` is an
/// OPAQUE sqid: never parse it, assume a length, or restrict its alphabet —
/// the sqid alphabet is environment-configurable and can contain `-`/`_`.
/// Accepts both the self-closing form the model is instructed to emit
/// (`<kb-image id="X"/>`) and a paired one (`<kb-image id="X"></kb-image>`).
final RegExp kbImageTagRegex = RegExp(
  r'<kb-image\s+id="([^"\s]+)"\s*/?>(?:\s*</kb-image>)?',
);

/// `TagService.escapeKbImageTags` swaps every raw `<kb-image id="X"/>` for
/// this placeholder (`kbImagePlaceholderStart` + id + `kbImagePlaceholderEnd`)
/// before the text reaches `MarkdownBody`, and [KbImageSyntax] matches THIS,
/// never the raw tag.
///
/// Why: `<kb-image id="X"/>` is a self-closing void tag that always sits
/// alone on its own line (nothing else on it). That's exactly CommonMark
/// HTML-block rule 7 ("a line consisting of a complete open/close tag and
/// nothing else") — the `markdown` package swallows the WHOLE line as a raw
/// HTML passthrough block *before inline parsing ever runs*, so an
/// `InlineSyntax` (this app's only tool for custom tags) never sees it.
/// Every other custom tag in this app dodges the rule some other way
/// (`[n]`/`【n】` markers never start with `<` at all; a mermaid graph tag
/// gets flattened onto one line with its content glued directly after the
/// opening tag, so the line is never "just a tag"). A kb-image tag has no
/// content to glue to, so it needs its own escape step.
/// Control characters U+0002/U+0003 are used because they can never appear
/// in normal model output or collide with markdown syntax.
const String kbImagePlaceholderStart = 'kb-image:';
const String kbImagePlaceholderEnd = '';

/// What [KbImageSyntax] actually matches — see [kbImagePlaceholderStart].
final RegExp kbImagePlaceholderRegex = RegExp(
  'kb-image:([^]+)',
);

/// One KB image citable in a turn. Mirror of the backend's
/// `ISseKbImage` (live `kb` frame) / `extraInfo.kbImages` entry (history).
///
/// This is the turn's **allowlist**: a `<kb-image id="X"/>` only renders (and
/// only gets fetched) when `X` matches one of these — the model can invent or
/// copy a stray id, and an id outside the allowlist must render nothing, not
/// an error or a broken-image placeholder (§5.2).
class KbImageRef {
  /// sqid of the embedding row — opaque, see [kbImageTagRegex] doc.
  final String id;

  /// Data source / document name, already HTML-escaped server-side.
  final String? name;

  /// 1-based page in the source document, when known.
  final int? pageNumber;

  /// Intrinsic px of the derived JPEG — live (`kb` frame) only, used to
  /// reserve layout space before the thumbnail loads. Absent on history
  /// reload (`extraInfo.kbImages` doesn't carry it).
  final int? width;
  final int? height;

  const KbImageRef({
    required this.id,
    this.name,
    this.pageNumber,
    this.width,
    this.height,
  });

  factory KbImageRef.fromMap(Map<String, dynamic> json) => KbImageRef(
    id: getString(json['id']),
    name: getStringOrNull(json['name']),
    pageNumber: getIntOrNull(json['pageNumber']),
    width: getIntOrNull(json['width']),
    height: getIntOrNull(json['height']),
  );

  /// Merges a later ref for the same [id] over this one — size hints seen
  /// live should survive a history-shaped ref (no width/height) landing on
  /// top of them, same merge rule as the web client's `KbImageService`.
  KbImageRef mergedWith(KbImageRef other) => KbImageRef(
    id: id,
    name: other.name ?? name,
    pageNumber: other.pageNumber ?? pageNumber,
    width: other.width ?? width,
    height: other.height ?? height,
  );
}
