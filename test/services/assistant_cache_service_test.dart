import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';

Assistant _assistant(
  String id, {
  AssistantType type = AssistantType.assistant,
}) => Assistant(
  id: id,
  name: 'Agent $id',
  description: '',
  imageUuid: '',
  welcomeMessage: '',
  customActions: const [],
  type: type,
  replyMode: ReplyMode.open,
);

void main() {
  tearDown(() async {
    await AssistantCacheService.clear();
  });

  group('AssistantCacheService', () {
    test('keyFor uses the normal-agent prefix', () {
      expect(AssistantCacheService.keyFor('abc', PupauAgentMode.assistant), 'pupau_agent_abc');
    });

    test('keyFor gives a Living Agent its own namespace', () {
      // A Living Agent is never cached (callers guard it), but the key must
      // not alias an assistant that happens to share the id - otherwise one
      // forgotten guard serves one aggregate's data as the other's.
      final String la =
          AssistantCacheService.keyFor('abc', PupauAgentMode.livingAgent);
      expect(la, 'pupau_living_agent_abc');
      expect(
        la,
        isNot(AssistantCacheService.keyFor('abc', PupauAgentMode.assistant)),
      );
      expect(
        la,
        isNot(AssistantCacheService.keyFor('abc', PupauAgentMode.marketplace)),
      );
    });

    test('keyFor uses the marketplace-agent prefix', () {
      expect(
        AssistantCacheService.keyFor('abc', PupauAgentMode.marketplace),
        'pupau_marketplace_agent_abc',
      );
    });

    test('put then get round-trips a normal agent', () async {
      final Assistant assistant = _assistant('a1');
      await AssistantCacheService.put(assistant);

      final Assistant? cached = await AssistantCacheService.get('a1', PupauAgentMode.assistant);
      expect(cached, same(assistant));
    });

    test(
      'a normal and marketplace agent with the same id are cached separately',
      () async {
        final Assistant normal = _assistant('same-id');
        final Assistant marketplace = _assistant(
          'same-id',
          type: AssistantType.marketplace,
        );
        await AssistantCacheService.put(normal);
        await AssistantCacheService.put(marketplace);

        expect(await AssistantCacheService.get('same-id', PupauAgentMode.assistant), same(normal));
        expect(
          await AssistantCacheService.get('same-id', PupauAgentMode.marketplace),
          same(marketplace),
        );
      },
    );

    test('remove evicts a cached agent', () async {
      await AssistantCacheService.put(_assistant('a1'));
      await AssistantCacheService.remove('a1', PupauAgentMode.assistant);

      expect(await AssistantCacheService.get('a1', PupauAgentMode.assistant), isNull);
    });

    test('evicts the least-recently-used agent once more than maxSize (20) '
        'normal + marketplace agents are cached', () async {
      for (int i = 0; i < AssistantCacheService.maxSize; i++) {
        await AssistantCacheService.put(_assistant('a$i'));
      }
      // One more than maxSize should evict the oldest ('a0').
      await AssistantCacheService.put(_assistant('a20'));

      expect(await AssistantCacheService.get('a0', PupauAgentMode.assistant), isNull);
      expect(await AssistantCacheService.get('a20', PupauAgentMode.assistant), isNotNull);
    });

    test('an id with only whitespace is not cached', () async {
      await AssistantCacheService.put(_assistant('   '));
      expect(await AssistantCacheService.get('   ', PupauAgentMode.assistant), isNull);
    });
  });
}
