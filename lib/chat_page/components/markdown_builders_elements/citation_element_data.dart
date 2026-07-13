import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

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
    if (origin != null && origin != GroundingOrigin.unknown) {
      attributes['origin'] = origin!.name;
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
    return attributes;
  }
}
