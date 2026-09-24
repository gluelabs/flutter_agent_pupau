import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

/// Which tier resolves a citation's source-panel preview
/// content, in priority order. A client that only ever reaches [fetchChunk]
/// shows [unavailable] for every web-search/knowledge-graph/attachment
/// citation.
enum CitationPreviewTier {
  /// §5.4: the cited chunk is an image (`mediaType: 'IMAGE'`) — show the
  /// thumbnail (same byte endpoint as inline `<kb-image>`), never a text
  /// snippet fetch.
  kbImage,
  fetchChunk,
  quote,
  url,
  attachment,
  unavailable,
}

/// Typed view over a `citation-chip` markdown element's string attributes
/// (set by [CitationSyntax] in `citation_syntax.dart`), consumed by
/// [CitationBuilder] to build a [CitationChip].
class CitationElementData {
  const CitationElementData({
    required this.citationNumber,
    this.queryId,
    this.origin,
    this.name,
    this.embeddingId,
    this.kbId,
    this.url,
    this.attachmentId,
    this.type,
    this.verdict,
    this.quote,
    this.quoteKind = GroundingQuoteKind.source,
    this.mediaType,
  });

  final int citationNumber;
  final String? queryId;
  final GroundingOrigin? origin;
  final String? name;
  final String? embeddingId;
  final String? kbId;
  final String? url;
  final String? attachmentId;
  final String? type;
  final GroundingVerdictType? verdict;

  /// `'TEXT'` (default) or `'IMAGE'` — an IMAGE chunk with an
  /// [embeddingId] shows a thumbnail instead of a text snippet, see
  /// [previewTier].
  final String? mediaType;

  /// Wire-provided source text for sources without an
  /// [embeddingId] to fetch. See [GroundingSource.quote].
  final String? quote;
  final GroundingQuoteKind quoteKind;

  /// [name], trimmed, or `[n]` when unresolved — used as the source panel's
  /// title.
  String get resolvedName {
    final String trimmed = (name ?? '').trim();
    return trimmed.isNotEmpty ? trimmed : '[$citationNumber]';
  }

  /// Pure origin-category label (Knowledge base / Web search / Attachment),
  /// falling back to `[n]` when [origin] isn't resolved yet — used as the
  /// source panel's subtitle line (always shown, independent of [name]).
  String get originCategoryLabel {
    switch (origin) {
      case GroundingOrigin.implicit:
      case GroundingOrigin.kbTool:
        return Strings.citationOriginKnowledgeBase.tr;
      case GroundingOrigin.webSearch:
        return Strings.citationOriginWebSearch.tr;
      case GroundingOrigin.attachment:
        return Strings.attachment.tr;
      case GroundingOrigin.unknown:
      case null:
        return '[$citationNumber]';
    }
  }

  /// Single-line label for [CitationChip]'s tooltip: [name] when known,
  /// otherwise the origin category (never both, unlike the panel which shows
  /// them as separate title/subtitle lines).
  String get tooltipLabel {
    final String trimmed = (name ?? '').trim();
    return trimmed.isNotEmpty ? trimmed : originCategoryLabel;
  }

  /// Tier 1 gate: only chunk-backed origins (IMPLICIT/KB_TOOL)
  /// with both an [embeddingId] and a [queryId] can be resolved via the
  /// on-demand snippet endpoint (`GET /grounding/chunks/:embeddingId`) —
  /// everything else must fall through to [previewTier]'s next tier, never
  /// straight to "unavailable".
  bool get canFetchChunkSnippet =>
      (origin == GroundingOrigin.implicit ||
          origin == GroundingOrigin.kbTool) &&
      (embeddingId ?? '').isNotEmpty &&
      (queryId ?? '').isNotEmpty;

  /// Which tier resolves this citation's source-panel preview. Pure and
  /// independent of network state — [CitationPreviewTier.fetchChunk] and
  /// [CitationPreviewTier.kbImage] still need their actual fetch to run
  /// before they have content to show.
  CitationPreviewTier get previewTier {
    if (canFetchChunkSnippet) {
      return mediaType?.toUpperCase() == 'IMAGE'
          ? CitationPreviewTier.kbImage
          : CitationPreviewTier.fetchChunk;
    }
    if ((quote ?? '').trim().isNotEmpty) return CitationPreviewTier.quote;
    if ((url ?? '').isNotEmpty) return CitationPreviewTier.url;
    if ((attachmentId ?? '').isNotEmpty) return CitationPreviewTier.attachment;
    return CitationPreviewTier.unavailable;
  }

  /// Null when [attributes] doesn't carry a valid citation number —
  /// defensive only, `CitationSyntax` always sets one.
  static CitationElementData? fromAttributes(Map<String, String> attributes) {
    final int citationNumber = getInt(attributes['n']);
    if (citationNumber <= 0) return null;
    return CitationElementData(
      citationNumber: citationNumber,
      queryId: getString(attributes['queryId']),
      origin: GroundingOriginParsing.fromWireValue(
        getString(attributes['origin']),
      ),
      name: getString(attributes['name']),
      embeddingId: getString(attributes['embeddingId']),
      kbId: getString(attributes['kbId']),
      url: getString(attributes['url']),
      attachmentId: getString(attributes['attachmentId']),
      type: getString(attributes['type']),
      verdict: GroundingVerdictTypeParsing.fromWireValue(
        getString(attributes['verdict']),
      ),
      quote: getStringOrNull(attributes['quote']),
      quoteKind: GroundingQuoteKindParsing.fromWireValue(
        attributes['quoteKind'],
      ),
      mediaType: getStringOrNull(attributes['mediaType']),
    );
  }

  /// Serializes back to markdown element string attributes — the write side
  /// of [fromAttributes], used by `CitationSyntax` so the wire shape is
  /// defined once instead of being duplicated on both ends.
  Map<String, String> toAttributes() {
    final Map<String, String> attributes = <String, String>{
      'n': citationNumber.toString(),
    };
    if ((queryId ?? '').isNotEmpty) attributes['queryId'] = queryId!;
    final String? wireOrigin = origin?.wireValue;
    if (wireOrigin != null) {
      attributes['origin'] = wireOrigin;
    }
    if ((name ?? '').isNotEmpty) attributes['name'] = name!;
    if ((embeddingId ?? '').isNotEmpty) attributes['embeddingId'] = embeddingId!;
    if ((kbId ?? '').isNotEmpty) attributes['kbId'] = kbId!;
    if ((url ?? '').isNotEmpty) attributes['url'] = url!;
    if ((attachmentId ?? '').isNotEmpty) {
      attributes['attachmentId'] = attachmentId!;
    }
    if ((type ?? '').isNotEmpty) attributes['type'] = type!;
    if (verdict != null && verdict != GroundingVerdictType.unknown) {
      attributes['verdict'] = verdict!.name;
    }
    if ((quote ?? '').isNotEmpty) {
      attributes['quote'] = quote!;
      if (quoteKind == GroundingQuoteKind.bestMatch) {
        attributes['quoteKind'] = quoteKind.wireValue;
      }
    }
    if ((mediaType ?? '').isNotEmpty) attributes['mediaType'] = mediaType!;
    return attributes;
  }
}
