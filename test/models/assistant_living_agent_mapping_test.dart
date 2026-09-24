import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Payload shape of `GET /living-agents/:livingAgentId` (autobot-ws
/// `LivingAgentEntity` + `withEffectiveFields`). It is NOT an assistant
/// payload: `capabilities` is a jsonb object, the image lives in
/// `avatarUuid`, and there is no `assistantSettings`.
Map<String, dynamic> livingAgentPayload() => <String, dynamic>{
  'id': 'etILjI',
  'name': 'Pupau',
  'kind': 'PERSONAL',
  'status': 'ACTIVE',
  'ownerUserId': 'Yu5ST',
  'avatarUuid': 'a1b2c3d4-0000-0000-0000-000000000000',
  'persona': <String, dynamic>{'tone': 'friendly'},
  'capabilities': <String, dynamic>{'responseModelId': 12, 'promptTier': 'v2'},
  'effectiveTools': <String, dynamic>{'memory': true},
  'effectivePromptTier': 'v2',
};

void main() {
  group('Living Agent payload → Assistant', () {
    test('fromMap does not throw on the jsonb capabilities object', () {
      // Regression: `json["capabilities"] as List<dynamic>` threw a TypeError,
      // AssistantService.getAssistant swallowed it and returned null, and the
      // chat rendered ApiErrorWidget ("Oh no! Something went wrong!").
      expect(() => Assistant.fromMap(livingAgentPayload()), returnsNormally);
    });

    test('fromLivingAgentMap carries the identity the chat header needs', () {
      final Assistant a = Assistant.fromLivingAgentMap(livingAgentPayload());

      expect(a.id, 'etILjI');
      expect(a.name, 'Pupau');
      expect(a.imageUuid, 'a1b2c3d4-0000-0000-0000-000000000000');
      // capabilities is an object on the wire and carries no assistant
      // capability list — it must not leak in as one.
      expect(a.capabilities, isEmpty);
      expect(a.type, AssistantType.assistant);
    });

    test('fromLivingAgentMap tolerates a minimal ensure/personal response', () {
      final Assistant a = Assistant.fromLivingAgentMap(<String, dynamic>{
        'id': 'etILjI',
        'name': 'Pupau',
        'kind': 'PERSONAL',
        'status': 'ACTIVE',
      });

      expect(a.id, 'etILjI');
      expect(a.name, 'Pupau');
      expect(a.imageUuid, '');
      expect(a.usageSettings, isNull);
    });
  });
}
