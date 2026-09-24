import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// `handleReconnectFrame` drives the catch-up/live stream shared by the
/// assistant reconnect and the Living Agent reattach. Getting a terminal wrong
/// leaves the composer blocked behind a spinner that never resolves.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final String channel in const <String>[
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (MethodCall call) async => null,
      );
    }
  });

  PupauChatController buildController() => PupauChatController(
    config: PupauConfig.createWithToken(
      bearerToken: 'test-token',
      assistantId: 'etILjI',
      agentMode: PupauAgentMode.livingAgent,
    ),
  );

  String frame(String eventType, [Map<String, dynamic>? extra]) =>
      jsonEncode(<String, dynamic>{'eventType': eventType, ...?extra});

  group('handleReconnectFrame', () {
    for (final String terminal in const <String>[
      'run_completed',
      'run_stopped',
      'run_error',
    ]) {
      test('$terminal releases the composer', () {
        final PupauChatController c = buildController();
        c.isStreaming.value = true;
        c.assistantsReplying.value = 1;

        c.handleReconnectFrame(frame(terminal));

        expect(c.isStreaming.value, isFalse);
        expect(c.assistantsReplying.value, 0);
      });
    }

    test('a non-terminal event marks the run active', () {
      final PupauChatController c = buildController();
      expect(c.isStreaming.value, isFalse);

      c.handleReconnectFrame(frame('some_future_event'));

      expect(c.isStreaming.value, isTrue);
      expect(c.assistantsReplying.value, 1);
    });

    test('grounding_verified does not resurrect a finished run', () {
      // Catch-up can replay it for a turn that ended long ago (stale cursor),
      // so it must not be treated as "the run is active".
      final PupauChatController c = buildController();

      c.handleReconnectFrame(
        frame('grounding_verified', <String, dynamic>{
          'queryId': 'q1',
          'verified': <dynamic>[],
        }),
      );

      expect(c.isStreaming.value, isFalse);
      expect(c.assistantsReplying.value, 0);
    });

    test('empty, blank and unparseable frames change nothing', () {
      final PupauChatController c = buildController();

      expect(() => c.handleReconnectFrame(null), returnsNormally);
      expect(() => c.handleReconnectFrame('   '), returnsNormally);
      expect(() => c.handleReconnectFrame('not json'), returnsNormally);

      expect(c.isStreaming.value, isFalse);
      expect(c.assistantsReplying.value, 0);
    });

    test('a payload-less message frame is survived, still counted as a run', () {
      // Malformed on the wire: it reaches the generic non-terminal branch
      // (so the run IS marked active, by design) and only then fails to
      // parse - which must stay swallowed rather than kill the subscription.
      final PupauChatController c = buildController();

      expect(() => c.handleReconnectFrame(frame('message')), returnsNormally);

      expect(c.isStreaming.value, isTrue);
    });
  });
}
