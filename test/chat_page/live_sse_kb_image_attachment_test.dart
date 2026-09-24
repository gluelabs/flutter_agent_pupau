import 'dart:convert';

import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/kb_image_model.dart';
import 'package:flutter_test/flutter_test.dart';

// Replays a REAL captured turn
// verbatim, in order, straight into PupauChatController.manageSSEData (the
// live SSE listener's real entry point). Two frames split one <kb-image> tag
// exactly like the backend does mid-stream (seq 6/7), to prove the allowlist/
// text-merge pipeline reassembles it and attaches it to the visible message.
// The rendering half (does the reassembled tag actually paint a widget) is
// covered separately in live_sse_kb_image_render_test.dart — kept in its own
// file/testWidgets so it doesn't share a binding with this plain test() (a
// PupauChatController pulls in VoicePlaybackService/AudioPlayer, which needs
// testWidgets' platform-channel mocking to construct cleanly).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'live ingestion attaches both split kb-image tags and their allowlist '
    'to the visible message',
    () {
      final PupauChatController controller = PupauChatController(
        config: PupauConfig.createWithToken(
          bearerToken: 'test-token',
          assistantId: 'CEVzt',
        ),
      );
      controller.conversation.value = PupauConversation(
        id: 'conv-1',
        createdAt: DateTime.now(),
        title: 't',
        token: 'tok',
        userId: 'u1',
        assistantId: 'CEVzt',
        queryCount: 0,
        comment: '',
        userName: '',
        userSurname: '',
      );
      controller.messageNotifier.setAssistantId('CEVzt');
      controller.messageNotifier.setConversationId('conv-1');

      const List<String> rawFrames = [
        '{"id":"QYrUj","messageType":"EVENT","type":"CONVERSATION_TITLE_GENERATED","data":{"title":"Pupau User Creation Guide with Images"},"assistantName":"Bob S","chatBotId":"CEVzt","seq":1}',
        '{"id":"QYrUj","messageType":"LLM","type":"kb","assistantName":"Bob S","kbReferences":[],"groundingSources":[{"id":7,"origin":"IMPLICIT","mediaType":"TEXT","name":"Guida creazione utenti (2).docx","embeddingId":"2wjXO","kbId":"vaCei","dataSourceId":"vaCei","linkId":null,"type":"FILE","pageNumbers":["1"],"chunkOrder":"1","similarity":0.5143406391143799}],"kbImages":[{"id":"EenWg","name":"Guida creazione utenti (2).docx","width":2048,"height":797},{"id":"6dOZb","name":"Guida creazione utenti (2).docx","width":2048,"height":748}],"chatBotId":"CEVzt","seq":2}',
        '{"id":"QYrUj","messageType":"EVENT","type":"SKILL_LOADED","skillHashId":"uk86E","skillName":"answer_reflection","loadedBy":"user","chatBotId":"CEVzt","queryGroupId":"YUxTS-1789546257930","seq":3}',
        '{"id":"QYrUj","messageType":"LLM","message":"La creazione degli utenti in **Pupau** segue un processo strutturato in tre fasi","chatBotId":"CEVzt","seq":4}',
        '{"id":"QYrUj","messageType":"LLM","message":" principali [7]:\\n\\n### 1. Invito Utente\\nDalla sezione \\"Utenti\\", clicca su **+","chatBotId":"CEVzt","seq":5}',
        '{"id":"QYrUj","messageType":"LLM","message":" Invita utente**. Inserisci Nome, Cognome ed Email nel pop-up e conferma [7].\\n\\n<","chatBotId":"CEVzt","seq":6}',
        '{"id":"QYrUj","messageType":"LLM","message":"kb-image id=\\"EenWg\\"/>\\n\\n### 2. Configurazione Ruolo e Password\\nClicca sul nome","chatBotId":"CEVzt","seq":7}',
        '{"id":"QYrUj","messageType":"LLM","message":" dell\'utente creato per accedere al profilo [7]:\\n*   **Livello:** Assegna il ruolo (es","chatBotId":"CEVzt","seq":8}',
        '{"id":"QYrUj","messageType":"LLM","message":". \\"Amministratore Organizzazione\\") tramite il menu a tendina [7].\\n*   **Password:** Usa","chatBotId":"CEVzt","seq":9}',
        '{"id":"QYrUj","messageType":"LLM","message":" \\"Reimposta password\\" per impostare le credenziali di accesso [7].\\n\\n<kb-image id=\\"6dO","chatBotId":"CEVzt","seq":10}',
        '{"id":"QYrUj","messageType":"LLM","message":"Zb\\"/>\\n\\n### 3. Gestione Permessi\\nPuoi affinare le autorizzazioni","chatBotId":"CEVzt","seq":11}',
      ];

      for (final String raw in rawFrames) {
        controller.manageSSEData(jsonDecode(raw) as Map<String, dynamic>, false);
      }

      expect(controller.messages, isNotEmpty);
      final message = controller.messages.first;
      expect(message.answer, contains('<kb-image id="EenWg"/>'));
      expect(message.answer, contains('<kb-image id="6dOZb"/>'));
      expect(
        message.kbImages.map((KbImageRef k) => k.id),
        containsAll(['EenWg', '6dOZb']),
      );
      expect(message.kbImagesQueryId, isNotNull);
    },
  );
}
