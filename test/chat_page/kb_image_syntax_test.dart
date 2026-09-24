import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/kb_image_syntax.dart';
import 'package:flutter_agent_pupau/models/kb_image_model.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markdown/markdown.dart' as md;

// `<kb-image id="X"/>` inline KB images. The central rule:
// an id outside the turn's allowlist must render NOTHING at all (no element,
// no literal tag text, no placeholder) — the model can invent or copy a
// stray sqid, and it must never even reach a fetch.
void main() {
  // KbImageSyntax matches TagService.escapeKbImageTags's placeholder, not
  // the raw tag (see kbImagePlaceholderStart's doc) — every input here is
  // raw model-shaped text, escaped first, exactly like MessageBody does via
  // TagService.convertTags before it ever reaches MarkdownBody.
  List<md.Node> parse(String text, List<KbImageRef> kbImages, {String? queryId}) {
    final doc = md.Document(
      inlineSyntaxes: [KbImageSyntax(kbImages, queryId)],
    );
    return doc.parseInline(TagService.escapeKbImageTags(text));
  }

  md.Element? firstKbImageElement(List<md.Node> nodes) {
    for (final node in nodes) {
      if (node is md.Element && node.tag == 'kb-image') return node;
    }
    return null;
  }

  group('kbImageTagRegex', () {
    test('matches the self-closing form the model is instructed to emit', () {
      expect(kbImageTagRegex.hasMatch('<kb-image id="Ab3-c_1"/>'), isTrue);
    });

    test('matches the paired form', () {
      expect(
        kbImageTagRegex.hasMatch('<kb-image id="Ab3"></kb-image>'),
        isTrue,
      );
    });

    test('matches without the self-closing slash', () {
      expect(kbImageTagRegex.hasMatch('<kb-image id="Ab3">'), isTrue);
    });
  });

  group('KbImageSyntax allowlist', () {
    final allowedRef = KbImageRef(id: 'img-1', name: 'chart.png', pageNumber: 2);

    test('an allowlisted id becomes a kb-image element with its ref fields', () {
      final nodes = parse(
        'testo <kb-image id="img-1"/> altro',
        [allowedRef],
        queryId: 'q1',
      );
      final element = firstKbImageElement(nodes);
      expect(element, isNotNull);
      expect(element!.attributes['id'], 'img-1');
      expect(element.attributes['queryId'], 'q1');
      expect(element.attributes['name'], 'chart.png');
      expect(element.attributes['pageNumber'], '2');
    });

    test(
      'an id NOT in the allowlist renders nothing: no element, no literal '
      'tag text',
      () {
        final nodes = parse(
          'testo <kb-image id="stray-invented-id"/> altro',
          [allowedRef],
          queryId: 'q1',
        );
        expect(firstKbImageElement(nodes), isNull);
        final String rendered = nodes
            .whereType<md.Text>()
            .map((t) => t.text)
            .join();
        expect(rendered.contains('kb-image'), isFalse);
        expect(rendered.contains('stray-invented-id'), isFalse);
      },
    );

    test('an empty allowlist drops every tag', () {
      final nodes = parse('<kb-image id="img-1"/>', const [], queryId: 'q1');
      expect(firstKbImageElement(nodes), isNull);
    });

    test('a size hint (live kb frame) is carried onto the element', () {
      final withSize = KbImageRef(id: 'img-2', width: 800, height: 400);
      final nodes = parse(
        '<kb-image id="img-2"/>',
        [withSize],
        queryId: 'q1',
      );
      final element = firstKbImageElement(nodes);
      expect(element, isNotNull);
      expect(element!.attributes['width'], '800');
      expect(element.attributes['height'], '400');
    });

    test('no queryId available -> element still built without one', () {
      final nodes = parse('<kb-image id="img-1"/>', [allowedRef]);
      final element = firstKbImageElement(nodes);
      expect(element, isNotNull);
      expect(element!.attributes.containsKey('queryId'), isFalse);
    });
  });
}
