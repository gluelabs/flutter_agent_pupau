import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_body.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/kb_image_inline.dart';
import 'package:flutter_agent_pupau/models/kb_image_model.dart';

// Renders the fully-merged answer from the captured turn
// (a real captured turn, reassembled from its split frames — see
// live_sse_kb_image_attachment_test.dart for the ingestion half) through the
// real MessageBody -> TagService.convertTags -> MarkdownBody -> KbImageSyntax
// -> KbImageBuilder pipeline. Both tags sit blank-line-separated from
// surrounding paragraphs, the shape that triggers CommonMark's HTML-block
// rule 7 and swallows a bare `<kb-image .../>` line whole before any
// InlineSyntax runs, unless the escape step in TagService.convertTags
// neutralizes it first.
void main() {
  testWidgets(
    'both <kb-image> tags in a real multi-paragraph answer render as '
    'KbImageInline widgets',
    (tester) async {
      const String answer =
          'La creazione degli utenti in **Pupau** segue un processo strutturato in tre fasi principali [7]:\n\n'
          '### 1. Invito Utente\n'
          'Dalla sezione "Utenti", clicca su **+ Invita utente**. Inserisci Nome, Cognome ed Email nel pop-up e conferma [7].\n\n'
          '<kb-image id="EenWg"/>\n\n'
          '### 2. Configurazione Ruolo e Password\n'
          'Clicca sul nome dell\'utente creato per accedere al profilo [7]:\n'
          '*   **Livello:** Assegna il ruolo (es. "Amministratore Organizzazione") tramite il menu a tendina [7].\n'
          '*   **Password:** Usa "Reimposta password" per impostare le credenziali di accesso [7].\n\n'
          '<kb-image id="6dOZb"/>\n\n'
          '### 3. Gestione Permessi\n'
          'Puoi affinare le autorizzazioni.';

      final List<KbImageRef> kbImages = [
        KbImageRef(id: 'EenWg', name: 'Guida creazione utenti (2).docx', width: 2048, height: 797),
        KbImageRef(id: '6dOZb', name: 'Guida creazione utenti (2).docx', width: 2048, height: 748),
      ];

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Row(
                children: [
                  MessageBody(
                    messageId: 'QYrUj',
                    message: answer,
                    isFromAssistant: true,
                    isAnonymous: false,
                    kbImages: kbImages,
                    kbImagesQueryId: 'QYrUj',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final Finder finder = find.byType(KbImageInline);
      expect(finder, findsNWidgets(2));
      final List<String> ids = tester
          .widgetList<KbImageInline>(finder)
          .map((KbImageInline w) => w.embeddingId)
          .toList();
      expect(ids, containsAll(['EenWg', '6dOZb']));
    },
  );
}
