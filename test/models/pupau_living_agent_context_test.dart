import 'package:flutter_agent_pupau/models/pupau_living_agent_context.dart';
import 'package:flutter_test/flutter_test.dart';

/// `contextRefs` is what lets the agent read the record a conversation was
/// started about. The backend rejects the WHOLE request when the array is
/// malformed or over its cap, so a bad ref must be dropped here rather than
/// cost the user their turn.
void main() {
  group('PupauLivingAgentContext', () {
    test('relays a ref unchanged, whatever its shape', () {
      // Shapes differ per kind and the plugin does not interpret them.
      const Map<String, dynamic> event = <String, dynamic>{
        'kind': 'EVENT',
        'surfaceKey': 'gcal:primary',
        'eventId': 'abc_20280808T080000Z',
        'label': 'Stand Up',
      };
      final PupauLivingAgentContext context =
          PupauLivingAgentContext(contextRefs: <Map<String, dynamic>>[event]);

      expect(context.toBodyFields()['contextRefs'], <Map<String, dynamic>>[event]);
    });

    test('drops a ref with no usable kind', () {
      final PupauLivingAgentContext context = PupauLivingAgentContext(
        contextRefs: <Map<String, dynamic>>[
          <String, dynamic>{'id': 'V6j7O'},
          <String, dynamic>{'kind': '', 'id': 'x'},
          <String, dynamic>{'kind': 42, 'id': 'y'},
          <String, dynamic>{'kind': 'ITEM', 'id': 'keep'},
        ],
      );
      expect(context.contextRefs.length, 1);
      expect(context.contextRefs.single['id'], 'keep');
    });

    test('caps at the backend maximum instead of losing the request', () {
      final PupauLivingAgentContext context = PupauLivingAgentContext(
        contextRefs: List<Map<String, dynamic>>.generate(
          25,
          (int i) => <String, dynamic>{'kind': 'ITEM', 'id': '$i'},
        ),
      );
      expect(context.contextRefs.length,
          PupauLivingAgentContext.maxContextRefs);
    });

    test('an empty context contributes no body fields at all', () {
      // Not `contextRefs: []` — an empty array is a value the backend would
      // have to validate; absence is what "no context" means.
      expect(PupauLivingAgentContext().toBodyFields(), isEmpty);
      expect(
        PupauLivingAgentContext(
          contextRefs: <Map<String, dynamic>>[<String, dynamic>{'id': 'no-kind'}],
        ).toBodyFields(),
        isEmpty,
      );
    });

    test('the body list is growable, since the HTTP layer may add to it', () {
      final PupauLivingAgentContext context = PupauLivingAgentContext(
        contextRefs: <Map<String, dynamic>>[
          <String, dynamic>{'kind': 'ITEM', 'id': 'a'},
        ],
      );
      final List<dynamic> refs =
          context.toBodyFields()['contextRefs'] as List<dynamic>;
      expect(() => refs.add(<String, dynamic>{'kind': 'NEWS', 'id': 'b'}),
          returnsNormally);
      // The source stays unmodifiable, so one turn cannot mutate another's.
      expect(() => context.contextRefs.add(<String, dynamic>{}),
          throwsUnsupportedError);
    });
  });
}
