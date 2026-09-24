import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_syntax.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

void main() {
  GroundingSource source({
    int id = 2,
    String name = 'Guida.docx',
    String origin = 'IMPLICIT',
    String mediaType = 'TEXT',
    String? url,
    String? quote,
    String? quoteKind,
  }) => GroundingSource.fromMap({
    'id': id,
    'origin': origin,
    'mediaType': mediaType,
    'name': name,
    'embeddingId': origin == 'IMPLICIT' || origin == 'KB_TOOL' ? '2wjXO' : null,
    if (url != null) 'url': url,
    if (quote != null) 'quote': quote,
    if (quoteKind != null) 'quoteKind': quoteKind,
  });

  List<md.Node> parse(String text, GroundingInfo? grounding) {
    final doc = md.Document(inlineSyntaxes: [CitationSyntax(grounding)]);
    return doc.parseInline(text);
  }

  CitationElementData? firstChip(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Element && node.tag == 'citation-chip') {
        return CitationElementData.fromAttributes(
          node.attributes,
        );
      }
    }
    return null;
  }

  group('citationMarkerRegex', () {
    test('matches ASCII [n]', () {
      expect(citationMarkerRegex.hasMatch('text [2] more'), isTrue);
    });

    test('matches CJK fullwidth 【n】', () {
      expect(citationMarkerRegex.hasMatch('testo【2】altro'), isTrue);
    });
  });

  group('CitationSyntax', () {
    final grounding = GroundingInfo(
      mode: 'CITATIONS',
      sources: [source()],
      citedIds: [2],
    );

    test('renders an ASCII [n] marker as a citation chip', () {
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.citationNumber, 2);
      expect(chip.name, 'Guida.docx');
    });

    test('renders a CJK fullwidth 【n】 marker as a citation chip', () {
      final chip = firstChip(parse('vedi qui【2】.', grounding));
      expect(chip, isNotNull);
      expect(chip!.citationNumber, 2);
      expect(chip.name, 'Guida.docx');
    });

    test('falls back to plain text for an uncited fullwidth marker', () {
      final nodes = parse('vedi qui【9】.', grounding);
      expect(nodes.whereType<md.Element>(), isEmpty);
    });
  });

  group('origin round-trips through the markdown element attributes', () {
    // CitationSyntax serializes CitationElementData to string attributes on
    // the md.Element (toAttributes), and CitationBuilder later reconstructs
    // it from those same strings (fromAttributes) when the widget tree is
    // actually built. A regression here (origin.name instead of the wire
    // value) silently degraded every multi-word origin to `unknown` — title
    // (a plain string attribute) kept working, so it only showed up as the
    // source panel's origin label and preview both falling back.
    for (final (wireOrigin, expected) in [
      ('IMPLICIT', GroundingOrigin.implicit),
      ('KB_TOOL', GroundingOrigin.kbTool),
      ('WEB_SEARCH', GroundingOrigin.webSearch),
      ('ATTACHMENT', GroundingOrigin.attachment),
    ]) {
      test('$wireOrigin round-trips to GroundingOrigin.${expected.name}', () {
        final grounding = GroundingInfo(
          mode: 'CITATIONS',
          sources: [source(origin: wireOrigin, url: 'https://example.com')],
          citedIds: [2],
        );
        final chip = firstChip(parse('vedi qui [2].', grounding));
        expect(chip, isNotNull);
        expect(chip!.origin, expected);
      });
    }
  });

  group('quote/quoteKind round-trip', () {
    test('a SOURCE quote on a web-search source round-trips', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [
          source(
            origin: 'WEB_SEARCH',
            quote: 'The SERP snippet text.',
          ),
        ],
        citedIds: [2],
      );
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.quote, 'The SERP snippet text.');
      expect(chip.quoteKind, GroundingQuoteKind.source);
    });

    test('a BEST_MATCH quote on an attachment source round-trips', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [
          source(
            origin: 'ATTACHMENT',
            quote: 'Best-matching passage.',
            quoteKind: 'BEST_MATCH',
          ),
        ],
        citedIds: [2],
      );
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.quote, 'Best-matching passage.');
      expect(chip.quoteKind, GroundingQuoteKind.bestMatch);
    });

    test('absent quoteKind on a quote-bearing source defaults to source', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [source(origin: 'ATTACHMENT', quote: 'Some text.')],
        citedIds: [2],
      );
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.quoteKind, GroundingQuoteKind.source);
    });

    test('no quote on the source -> null on the chip', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [source()],
        citedIds: [2],
      );
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.quote, isNull);
    });
  });

  group('mediaType round-trip', () {
    test('IMAGE mediaType round-trips onto the chip', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [source(mediaType: 'IMAGE')],
        citedIds: [2],
      ).withQueryId('q1');
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.mediaType, 'IMAGE');
      expect(chip.previewTier, CitationPreviewTier.kbImage);
    });

    test('default TEXT mediaType keeps the normal fetch tier', () {
      final grounding = GroundingInfo(
        mode: 'CITATIONS',
        sources: [source()],
        citedIds: [2],
      ).withQueryId('q1');
      final chip = firstChip(parse('vedi qui [2].', grounding));
      expect(chip, isNotNull);
      expect(chip!.mediaType, 'TEXT');
      expect(chip.previewTier, CitationPreviewTier.fetchChunk);
    });
  });
}
