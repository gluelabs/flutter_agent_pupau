import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// `GET /living-agents/:id/conversations/:conversationId` — autobot-ws
/// `ILaConversationTranscript`: an ENVELOPE, not a conversation.
Map<String, dynamic> transcriptPayload({
  String runState = 'done',
  dynamic resumeEventId,
}) => <String, dynamic>{
  'conversation': <String, dynamic>{
    'id': 'h65W9',
    'title': 'Preparazione riunione',
    'source': 'APP',
    'status': 'OPEN',
    'createdAt': '2026-09-16T08:55:00.000Z',
    'lastActivityAt': '2026-09-16T09:00:00.000Z',
  },
  'messages': <dynamic>[
    <String, dynamic>{
      'id': 'q1',
      'question': 'Aiutami a preparare la riunione',
      'answer': 'Ecco una prima scaletta...',
      'toolSuccess': true,
      'createdAt': '2026-09-16T09:00:00.000Z',
      'queryGroupId': 'g1',
      'type': 'LLM',
      'extraInfo': <String, dynamic>{},
    },
  ],
  'runState': runState,
  'resumeEventId': resumeEventId,
};

void main() {
  group('LivingAgentTranscript', () {
    test('reads the conversation from the envelope, not from its root', () {
      // Regression: PupauConversation.fromMap(response.data) is tolerant, so
      // the envelope yielded a conversation with an EMPTY id instead of
      // failing — the chat then opened on an empty thread.
      final LivingAgentTranscript t = LivingAgentTranscript.fromMap(
        transcriptPayload(),
      );

      expect(t.conversation.id, 'h65W9');
      expect(t.conversation.title, 'Preparazione riunione');
      expect(t.messages, hasLength(1));
    });

    test('the naive root mapping is what produced the empty conversation', () {
      final PupauConversation wrong = PupauConversation.fromMap(
        transcriptPayload(),
      );
      expect(wrong.id, isEmpty);
    });

    test('history rows map through the shared REST shaping', () {
      final LivingAgentTranscript t = LivingAgentTranscript.fromMap(
        transcriptPayload(),
      );
      final PupauMessage m = PupauMessage.fromLoadedChat(
        Map<String, dynamic>.from(t.messages.first as Map),
      );

      // The LA transcript names the user turn `question`; REST history uses
      // `query`. Both must land in `query`.
      expect(m.query, 'Aiutami a preparare la riunione');
      expect(m.answer, 'Ecco una prima scaletta...');
    });

    test('isRunning drives the reattach decision', () {
      expect(
        LivingAgentTranscript.fromMap(
          transcriptPayload(runState: 'running', resumeEventId: 'ev42'),
        ).isRunning,
        isTrue,
      );
      expect(
        LivingAgentTranscript.fromMap(transcriptPayload()).isRunning,
        isFalse,
      );
    });

    test('resumeEventId stays null when no run is live', () {
      expect(LivingAgentTranscript.fromMap(transcriptPayload()).resumeEventId,
          isNull);
      expect(
        LivingAgentTranscript.fromMap(
          transcriptPayload(runState: 'running', resumeEventId: 'ev42'),
        ).resumeEventId,
        'ev42',
      );
    });

    test('a missing runState is not invented', () {
      final LivingAgentTranscript t = LivingAgentTranscript.fromMap(
        <String, dynamic>{'conversation': <String, dynamic>{'id': 'h65W9'}},
      );
      expect(t.runState, isEmpty);
      expect(t.isRunning, isFalse);
      expect(t.messages, isEmpty);
    });
  });
}
