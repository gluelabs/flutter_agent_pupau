import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_body.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/kb_image_inline.dart';
import 'package:flutter_agent_pupau/models/kb_image_model.dart';

// Pumps the real MessageBody widget tree (MarkdownBody ->
// KbImageSyntax -> KbImageBuilder -> KbImageInline) the same way
// message_body_citation_chip_test.dart does for citations, to catch a wiring
// bug a pure-parser test could miss.
void main() {
  Widget wrap(Widget child) =>
      GetMaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));

  Future<void> pumpAnswer(
    WidgetTester tester,
    String answer,
    List<KbImageRef> kbImages,
  ) async {
    await tester.pumpWidget(
      wrap(
        Row(
          children: [
            MessageBody(
              messageId: 'm1',
              message: answer,
              isFromAssistant: true,
              isAnonymous: false,
              kbImages: kbImages,
              kbImagesQueryId: 'q1',
            ),
          ],
        ),
      ),
    );
    await tester.pump();
  }

  // Real model output puts the tag on its OWN line, blank-line-separated
  // from surrounding paragraphs (`\n\n<kb-image .../>\n\n`) — that blank
  // line matters: it's what makes the line satisfy CommonMark's HTML-block
  // rule 7 ("a complete tag alone on a line, starting a fresh block"), which
  // swallows it before any InlineSyntax runs unless TagService.convertTags's
  // escape step neutralizes it first. A single `\n` (no paragraph break)
  // would dodge the bug by accident and prove nothing — always use `\n\n`
  // here.
  testWidgets('an allowlisted <kb-image> renders a KbImageInline widget', (
    tester,
  ) async {
    await pumpAnswer(
      tester,
      'ecco il grafico\n\n<kb-image id="img-1"/>\n\naltro testo',
      [KbImageRef(id: 'img-1', name: 'grafico.png')],
    );

    final finder = find.byType(KbImageInline);
    expect(finder, findsOneWidget);
    final KbImageInline widget = tester.widget(finder);
    expect(widget.embeddingId, 'img-1');
    expect(widget.queryId, 'q1');
  });

  testWidgets(
    'a <kb-image> id outside the allowlist renders nothing — no widget, '
    'no literal tag text',
    (tester) async {
      await pumpAnswer(
        tester,
        'ecco il grafico\n\n<kb-image id="stray-id"/>\n\naltro testo',
        [KbImageRef(id: 'img-1', name: 'grafico.png')],
      );

      expect(find.byType(KbImageInline), findsNothing);
      expect(find.textContaining('kb-image'), findsNothing);
      expect(find.textContaining('stray-id'), findsNothing);
    },
  );
}
