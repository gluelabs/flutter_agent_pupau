import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_body.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/kb_image_inline.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/message_service.dart';

// History reload: extraInfo.kbImages + the persisted answer text
// (no real history capture was available when first reported, so this
// mirrors the real shape from the SSE example's kbImages entries and the
// backend's documented `extraInfo` shape instead). Same root cause as the
// live case (live_sse_kb_image_render_test.dart): a `<kb-image id="X"/>`
// alone on its own blank-line-separated line satisfies CommonMark's
// HTML-block rule 7 regardless of whether the text came from a live stream
// or a REST history payload — MessageBody's rendering path (and its
// TagService.convertTags escape step) is the same for both.
void main() {
  testWidgets(
    'a <kb-image> tag persisted in history answer + extraInfo.kbImages '
    'renders as a KbImageInline widget',
    (tester) async {
      final PupauMessage message = PupauMessage.fromLoadedChat({
        'id': 125389,
        'createdAt': '2026-09-17T10:00:00.000Z',
        'query': 'crea un utente',
        'answer':
            'Ecco la guida:\n\n<kb-image id="EenWg"/>\n\nSegui questi passaggi.',
        'chatBotId': 361,
        'conversationId': 68228,
        'type': 'LLM',
        'extraInfo': {
          'kbImages': [
            {
              'id': 'EenWg',
              'name': 'Guida creazione utenti (2).docx',
              'pageNumber': 1,
            },
          ],
        },
      });

      expect(message.kbImages.map((k) => k.id), contains('EenWg'));
      expect(message.kbImagesQueryId, '125389');

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Row(
                children: [
                  MessageBody(
                    messageId: message.id,
                    message: message.answer,
                    isFromAssistant: true,
                    isAnonymous: false,
                    kbImages: message.kbImages,
                    kbImagesQueryId: message.kbImagesQueryId,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final Finder finder = find.byType(KbImageInline);
      expect(finder, findsOneWidget);
      final KbImageInline widget = tester.widget(finder);
      expect(widget.embeddingId, 'EenWg');
      expect(widget.queryId, '125389');
    },
  );

  test(
    'MessageService.getAssistantLoadedMessage forwards kbImages and '
    'kbImagesQueryId onto the rebuilt message (regression: the rendered row '
    'is this rebuilt object, not the one fromLoadedChat produced — dropping '
    'these fields here made every history-loaded kb-image render nothing, '
    'even though fromLoadedChat itself parsed them correctly)',
    () {
      final PupauMessage loaded = PupauMessage.fromLoadedChat({
        'id': 125389,
        'createdAt': '2026-09-17T10:00:00.000Z',
        'query': 'crea un utente',
        'answer':
            'Ecco la guida:\n\n<kb-image id="EenWg"/>\n\nSegui questi passaggi.',
        'chatBotId': 361,
        'conversationId': 68228,
        'type': 'LLM',
        'extraInfo': {
          'kbImages': [
            {
              'id': 'EenWg',
              'name': 'Guida creazione utenti (2).docx',
              'pageNumber': 1,
            },
          ],
        },
      });

      final PupauMessage rebuilt = MessageService.getAssistantLoadedMessage(
        loaded,
      );

      expect(rebuilt.kbImages.map((k) => k.id), contains('EenWg'));
      expect(rebuilt.kbImagesQueryId, '125389');
    },
  );

  // Real `event: history` payload shape, captured from staging, which
  // differs from the synthetic fixtures above in three ways that each could
  // have broken rendering independently: FOUR tags rather than one; each tag
  // indented four spaces as continuation content of an ordered-list item
  // rather than isolated between blank lines; and kbImages entries carrying
  // only {id, name} — no pageNumber/width/height, so the size hint is absent
  // and KbImageInline must fall back rather than assume the live-frame shape.
  testWidgets(
    'real-world history payload: 4 kb-images indented inside ordered-list '
    'items, refs without pageNumber/width/height, through the full '
    'getAssistantLoadedMessage chain',
    (tester) async {
      final PupauMessage loaded = PupauMessage.fromLoadedChat({
        'id': '2RArV',
        'createdAt': '2026-09-16T09:38:06.399Z',
        'query': 'Parlami della creazione utenti Pupau',
        'answer':
            'Per creare o gestire utenti su Pupau:\n\n'
            '1.  **Gestione Utenti Organizzazione**: Dalle "Impostazioni > '
            'Utenti" puoi invitare nuovi membri [9].\n'
            '    <kb-image id="6dOZb"/>\n'
            '    <kb-image id="EenWg"/>\n\n'
            '2.  **Accesso ai Singoli Agenti**: la sezione "Utenti e accessi" '
            'permette di aggiungere accessi mirati [6][8].\n'
            '    <kb-image id="kfNPf"/>\n'
            '    <kb-image id="1BRo9"/>\n',
        'chatBotId': 'CEVzt',
        'conversationId': 'xLVxv',
        'type': 'LLM',
        'extraInfo': {
          'kbImages': [
            {'id': '6dOZb', 'name': 'Guida creazione utenti (2).docx'},
            {'id': 'EenWg', 'name': 'Guida creazione utenti (2).docx'},
            {'id': 'kfNPf', 'name': 'Guida creazione utenti (2).docx'},
            {'id': '1BRo9', 'name': 'Guida creazione utenti (2).docx'},
          ],
        },
      });

      final PupauMessage message = MessageService.getAssistantLoadedMessage(
        loaded,
      );
      expect(message.kbImages.length, 4);
      expect(message.kbImagesQueryId, '2RArV');

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Row(
                children: [
                  MessageBody(
                    messageId: message.id,
                    message: message.answer,
                    isFromAssistant: true,
                    isAnonymous: false,
                    kbImages: message.kbImages,
                    kbImagesQueryId: message.kbImagesQueryId,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(KbImageInline), findsNWidgets(4));
      final List<String> rendered = tester
          .widgetList<KbImageInline>(find.byType(KbImageInline))
          .map((KbImageInline w) => w.embeddingId)
          .toList();
      expect(rendered, ['6dOZb', 'EenWg', 'kfNPf', '1BRo9']);
    },
  );
}
