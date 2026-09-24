import 'dart:async';

import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A Living Agent conversation is created by its FIRST MESSAGE, and the only
/// announcement of its id is the `la_thread` SSE frame. The host's history
/// drawer has no other way to learn which conversation the chat is on, so the
/// event that carries it is a wire contract.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // PupauChatController builds a VoicePlaybackService, whose AudioPlayer calls
  // into a platform channel. Unmocked it rejects asynchronously, and these
  // tests await - so the rejection lands inside them instead of after.
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

  test('la_thread adopts the conversation and announces it to the host', () async {
    final PupauChatController controller = buildController();
    final Completer<PupauEvent> announced = Completer<PupauEvent>();
    final StreamSubscription<PupauEvent> sub = PupauEventService.pupauStream
        .listen((PupauEvent event) {
          if (event.type == UpdateConversationType.newConversation &&
              !announced.isCompleted) {
            announced.complete(event);
          }
        });
    addTearDown(sub.cancel);

    controller.manageSSEData(<String, dynamic>{
      'type': 'la_thread',
      'conversationId': 'h65W9',
    }, false);

    expect(controller.conversation.value?.id, 'h65W9');

    final PupauEvent event = await announced.future.timeout(
      const Duration(seconds: 2),
    );
    expect(event.payload['agentMode'], PupauAgentMode.livingAgent.name);
    final dynamic conversation = event.payload['conversation'];
    expect(conversation, isA<PupauConversation>());
    expect((conversation as PupauConversation).id, 'h65W9');
    // Living Agent chat authenticates with the bearer alone.
    expect(conversation.token, isEmpty);
  });

  test('re-adopting the same id mid-stream does not re-announce', () async {
    final PupauChatController controller = buildController();
    int announcements = 0;
    final StreamSubscription<PupauEvent> sub = PupauEventService.pupauStream
        .listen((PupauEvent event) {
          if (event.type == UpdateConversationType.newConversation) {
            announcements++;
          }
        });
    addTearDown(sub.cancel);

    const Map<String, dynamic> frame = <String, dynamic>{
      'type': 'la_thread',
      'conversationId': 'h65W9',
    };
    controller.manageSSEData(Map<String, dynamic>.from(frame), false);
    controller.manageSSEData(Map<String, dynamic>.from(frame), false);
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // A second adoption would look like a conversation change and reset the
    // turn in flight.
    expect(announcements, 1);
  });
}
