import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';

/// Intercepts `[n]` RAG citation markers (§1/§2 of the citations spec) and
/// turns them into a `citation-chip` element, or lets them through as plain
/// text when there's nothing to resolve them against.
///
/// Resolution rule:
/// - [grounding] is null (or `overridden`) → always plain text (covers
///   `A_GROUNDING_MODE=OFF` and guardrail-overridden turns, §1.3).
/// - `citedIds` empty (live, pre-refetch — not authoritative yet) →
///   optimistically render every complete `[n]` as a chip, with whatever
///   label is available.
/// - `citedIds` non-empty (authoritative, from history/refetch) → strict:
///   only `n` values present in `citedIds` become chips, everything else
///   falls back to plain text (spec's explicit "no matching source" rule).
///
/// IMPORTANT: `InlineSyntax.tryMatch` only advances the parser position when
/// `onMatch` returns `true` — returning `false` here would leave the parser
/// stuck re-matching the same `[n]` forever (an infinite loop), so this
/// syntax *always* returns `true` and explicitly decides between adding a
/// `citation-chip` element or a literal [md.Text] node.
class CitationSyntax extends md.InlineSyntax {
  CitationSyntax(this.grounding) : super(citationMarkerPattern);

  final GroundingInfo? grounding;

  /// Per-source occurrence counter, local to one parse (one [CitationSyntax]
  /// instance is constructed fresh per `MessageBody.build()`, so this safely
  /// resets every rebuild and recomputes identically each time since matches
  /// are visited in document order).
  final Map<int, int> _occurrenceCounters = <int, int>{};

  bool _isAuthoritativelyCited(int n) {
    final GroundingInfo g = grounding!;
    if (g.citedIds.isEmpty) return true; // live, optimistic
    return g.citedIds.contains(n);
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final int citationNumber = int.tryParse(match[1] ?? '') ?? -1;
    final GroundingInfo? g = grounding;

    if (citationNumber <= 0 || g == null || g.overridden || !_isAuthoritativelyCited(citationNumber)) {
      parser.addNode(md.Text(match[0] ?? ''));
      return true;
    }

    final int occurrence = _occurrenceCounters[citationNumber] ?? 0;
    _occurrenceCounters[citationNumber] = occurrence + 1;

    final GroundingSource? source = g.sourceForMarker(citationNumber);
    final GroundingVerdict? verdict = g.verification?.verdictFor(
      citationNumber,
      occurrence,
    );

    final CitationElementData data = CitationElementData(
      citationNumber: citationNumber,
      queryId: g.queryId,
      origin: source?.origin,
      name: source?.name,
      embeddingId: source?.embeddingId,
      kbId: source?.kbId,
      url: source?.url,
      attachmentId: source?.attachmentId,
      type: source?.type,
      verdict: verdict?.verdict,
    );
    final md.Element element = md.Element.withTag('citation-chip');
    element.attributes.addAll(data.toAttributes());
    parser.addNode(element);
    return true;
  }
}
