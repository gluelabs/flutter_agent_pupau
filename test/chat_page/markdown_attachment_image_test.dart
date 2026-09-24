import 'package:flutter_agent_pupau/chat_page/components/markdown_builders_elements/markdown_attachment_image.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeMarkdownImageSrc', () {
    test('lower-cases and trims', () {
      expect(normalizeMarkdownImageSrc('  Grafico.PNG '), 'grafico.png');
    });

    test('strips a directory / sandbox prefix', () {
      expect(normalizeMarkdownImageSrc('/mnt/data/grafico.png'), 'grafico.png');
      expect(
        normalizeMarkdownImageSrc('sandbox:/workspace/out/chart.png'),
        'chart.png',
      );
    });

    test('percent-decodes', () {
      expect(normalizeMarkdownImageSrc('my%20chart.png'), 'my chart.png');
    });

    test('tolerates a malformed escape', () {
      expect(normalizeMarkdownImageSrc('100%.png'), '100%.png');
    });
  });

  group('markdownImageSrcMatchesAttachment', () {
    test('matches bare name against fileName + extension', () {
      expect(
        markdownImageSrcMatchesAttachment('grafico.png', 'grafico', 'png'),
        isTrue,
      );
    });

    test('matches when the src omits the extension', () {
      expect(
        markdownImageSrcMatchesAttachment('grafico', 'grafico', 'png'),
        isTrue,
      );
    });

    test('matches when fileName already carries the extension', () {
      expect(
        markdownImageSrcMatchesAttachment('grafico.png', 'grafico.png', 'png'),
        isTrue,
      );
    });

    test('matches a sandbox path against the bare attachment name', () {
      expect(
        markdownImageSrcMatchesAttachment(
          '/mnt/data/grafico.png',
          'grafico',
          'png',
        ),
        isTrue,
      );
    });

    test('does not match a different file', () {
      expect(
        markdownImageSrcMatchesAttachment('other.png', 'grafico', 'png'),
        isFalse,
      );
    });

    test('does not match on an empty src or empty fileName', () {
      expect(markdownImageSrcMatchesAttachment('', 'grafico', 'png'), isFalse);
      expect(
        markdownImageSrcMatchesAttachment('grafico.png', '', 'png'),
        isFalse,
      );
    });
  });
}
