import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/citation_element_data.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_test/flutter_test.dart';

// A source-panel body that only implements
// the chunk-fetch tier shows "Preview unavailable" on every citation without
// an embeddingId (web search, knowledge-graph evidence, attachments), even
// when the backend already put the text on the wire in `quote`. These tests
// pin the tier-resolution order directly, independent of network/widget
// state — CitationElementData.previewTier is what citation_source_panel_
// modal.dart's body switches on.
void main() {
  CitationElementData data({
    GroundingOrigin? origin,
    String? embeddingId,
    String? queryId,
    String? quote,
    GroundingQuoteKind quoteKind = GroundingQuoteKind.source,
    String? url,
    String? attachmentId,
    String? mediaType,
  }) => CitationElementData(
    citationNumber: 2,
    origin: origin,
    embeddingId: embeddingId,
    queryId: queryId,
    quote: quote,
    quoteKind: quoteKind,
    url: url,
    attachmentId: attachmentId,
    mediaType: mediaType,
  );

  group('previewTier', () {
    test('KB source with embeddingId + queryId -> fetchChunk', () {
      expect(
        data(
          origin: GroundingOrigin.implicit,
          embeddingId: 'abc',
          queryId: '123',
        ).previewTier,
        CitationPreviewTier.fetchChunk,
      );
      expect(
        data(
          origin: GroundingOrigin.kbTool,
          embeddingId: 'abc',
          queryId: '123',
        ).previewTier,
        CitationPreviewTier.fetchChunk,
      );
    });

    test(
      'web-search source with a quote and no embeddingId -> quote '
      '(this exact case regressed to "unavailable" before the tier fix)',
      () {
        expect(
          data(
            origin: GroundingOrigin.webSearch,
            quote: 'The SERP snippet text.',
          ).previewTier,
          CitationPreviewTier.quote,
        );
      },
    );

    test('knowledge-graph evidence quote (no embeddingId) -> quote', () {
      expect(
        data(quote: 'Authored evidence text.').previewTier,
        CitationPreviewTier.quote,
      );
    });

    test('attachment source with a quote -> quote, not the download action', () {
      expect(
        data(
          origin: GroundingOrigin.attachment,
          attachmentId: 'att-1',
          quote: 'Best-matching passage.',
        ).previewTier,
        CitationPreviewTier.quote,
      );
    });

    test('KB source missing queryId falls through to quote, not fetchChunk', () {
      expect(
        data(
          origin: GroundingOrigin.implicit,
          embeddingId: 'abc',
          quote: 'fallback text',
        ).previewTier,
        CitationPreviewTier.quote,
      );
    });

    test('web-search source with only a url -> url', () {
      expect(
        data(
          origin: GroundingOrigin.webSearch,
          url: 'https://example.com',
        ).previewTier,
        CitationPreviewTier.url,
      );
    });

    test('attachment source with only an attachmentId -> attachment', () {
      expect(
        data(
          origin: GroundingOrigin.attachment,
          attachmentId: 'att-1',
        ).previewTier,
        CitationPreviewTier.attachment,
      );
    });

    test('nothing resolvable -> unavailable', () {
      expect(data(origin: GroundingOrigin.attachment).previewTier,
          CitationPreviewTier.unavailable);
      expect(data().previewTier, CitationPreviewTier.unavailable);
    });

    test('blank/whitespace-only quote does not count as tier quote', () {
      expect(
        data(origin: GroundingOrigin.webSearch, quote: '   ').previewTier,
        CitationPreviewTier.unavailable,
      );
    });

    test('embeddingId present but wrong origin (e.g. attachment) does not '
        'reach fetchChunk', () {
      expect(
        data(
          origin: GroundingOrigin.attachment,
          embeddingId: 'abc',
          queryId: '123',
          attachmentId: 'att-1',
        ).previewTier,
        CitationPreviewTier.attachment,
      );
    });

    // A cited chunk that's an image gets a thumbnail, never
    // a text-snippet fetch.
    test('IMAGE mediaType chunk with embeddingId + queryId -> kbImage', () {
      expect(
        data(
          origin: GroundingOrigin.implicit,
          embeddingId: 'abc',
          queryId: '123',
          mediaType: 'IMAGE',
        ).previewTier,
        CitationPreviewTier.kbImage,
      );
    });

    test('mediaType comparison is case-insensitive', () {
      expect(
        data(
          origin: GroundingOrigin.kbTool,
          embeddingId: 'abc',
          queryId: '123',
          mediaType: 'image',
        ).previewTier,
        CitationPreviewTier.kbImage,
      );
    });

    test('TEXT (or absent) mediaType keeps the normal fetchChunk tier', () {
      expect(
        data(
          origin: GroundingOrigin.implicit,
          embeddingId: 'abc',
          queryId: '123',
          mediaType: 'TEXT',
        ).previewTier,
        CitationPreviewTier.fetchChunk,
      );
      expect(
        data(
          origin: GroundingOrigin.implicit,
          embeddingId: 'abc',
          queryId: '123',
        ).previewTier,
        CitationPreviewTier.fetchChunk,
      );
    });

    test('IMAGE mediaType without embeddingId still falls through normally', () {
      expect(
        data(
          origin: GroundingOrigin.webSearch,
          mediaType: 'IMAGE',
          quote: 'fallback text',
        ).previewTier,
        CitationPreviewTier.quote,
      );
    });
  });
}
