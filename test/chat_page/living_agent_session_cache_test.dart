import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One PupauChatController serves all three agent modes, so opening an
/// assistant used to wipe the Living Agent thread and force a refetch on the
/// way back. The session cache is what keeps it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final String channel in const <String>[
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
      'flutter_tts',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (MethodCall call) async => null,
      );
    }
    PupauChatController.clearLivingAgentSession();
  });

  tearDown(PupauChatController.clearLivingAgentSession);

  PupauConfig livingAgentConfig({String? conversationId}) =>
      PupauConfig.createWithToken(
        bearerToken: 'test-token',
        assistantId: 'etILjI',
        agentMode: PupauAgentMode.livingAgent,
        conversationId: conversationId,
      );

  PupauConfig assistantConfig() => PupauConfig.createWithToken(
    bearerToken: 'test-token',
    assistantId: 'CEVzt',
  );

  PupauMessage message(String id, String text) => PupauMessage(
    id: id,
    query: text,
    answer: 'answer $id',
    assistantId: 'etILjI',
    assistantType: AssistantType.assistant,
    createdAt: DateTime.now(),
    status: MessageStatus.received,
  );

  /// A controller already sitting on a Living Agent thread.
  PupauChatController controllerOnLivingAgentThread() {
    final PupauChatController c = PupauChatController(
      config: livingAgentConfig(),
    );
    c.assistant.value = Assistant(
      id: 'etILjI',
      name: 'Bob',
      description: '',
      imageUuid: '',
      welcomeMessage: '',
      customActions: const [],
      type: AssistantType.assistant,
      replyMode: ReplyMode.open,
    );
    c.conversation.value = PupauConversation(
      id: 'h65W9',
      createdAt: DateTime.now(),
      title: 'Preparazione riunione',
      token: '',
      userId: '',
      assistantId: 'etILjI',
      queryCount: 2,
      comment: '',
      userName: '',
      userSurname: '',
    );
    c.messages.assignAll(<PupauMessage>[
      message('m1', 'ciao'),
      message('m2', 'come stai'),
    ]);
    c.isConversationHistoryLoaded = true;
    return c;
  }

  test('the thread survives a visit to an assistant chat', () async {
    final PupauChatController c = controllerOnLivingAgentThread();

    // Leave for an assistant: this is what used to wipe it.
    await c.openChatWithConfig(assistantConfig());
    expect(c.messages, isEmpty, reason: 'the assistant chat starts clean');

    // Back to the Living Agent section.
    await c.openChatWithConfig(livingAgentConfig());

    expect(c.messages.map((PupauMessage m) => m.id), <String>['m1', 'm2']);
    expect(c.conversation.value?.id, 'h65W9');
    // Restored, not refetched: the header keeps the agent it had.
    expect(c.assistant.value?.name, 'Bob');
    expect(c.isConversationHistoryLoaded, isTrue);
  });

  test('the restore lands before any frame can be painted', () async {
    final PupauChatController c = controllerOnLivingAgentThread();
    await c.openChatWithConfig(assistantConfig());

    // Deliberately NOT awaited. PupauAgentChat schedules openChatWithConfig in
    // a microtask, which completes before the next frame — so whatever is true
    // at this point is what the user sees. An `await` sneaking in ahead of the
    // restore would let a skeleton frame through, which is the flicker this
    // guards against.
    final Future<void> pending = c.openChatWithConfig(livingAgentConfig());

    expect(c.messages.map((PupauMessage m) => m.id), <String>['m1', 'm2']);
    expect(c.isChatEntryResolving.value, isFalse);
    expect(c.isLoadingConversation.value, isFalse);

    await pending;
  });

  test('a turn still streaming is not frozen — it reattaches instead', () async {
    final PupauChatController c = controllerOnLivingAgentThread();
    c.isStreaming.value = true;
    c.assistantsReplying.value = 1;

    await c.openChatWithConfig(assistantConfig());
    await c.openChatWithConfig(livingAgentConfig());

    // Nothing replayed: the run continued server-side and the way back in is
    // the transcript's runState/resumeEventId, not a half-answer snapshot.
    expect(c.messages, isEmpty);
  });

  test('asking for a different conversation wins over the frozen one', () async {
    final PupauChatController c = controllerOnLivingAgentThread();

    await c.openChatWithConfig(assistantConfig());
    await c.openChatWithConfig(livingAgentConfig(conversationId: 'OTHER'));

    // The caller asked for a specific thread; restoring the old one would
    // silently show the wrong conversation.
    expect(c.messages, isEmpty);
  });

  test('an empty thread is not worth restoring', () async {
    final PupauChatController c = PupauChatController(
      config: livingAgentConfig(),
    );

    await c.openChatWithConfig(assistantConfig());
    await c.openChatWithConfig(livingAgentConfig());

    expect(c.messages, isEmpty);
  });

  test('clearLivingAgentSession drops it, e.g. on a new bearer', () async {
    final PupauChatController c = controllerOnLivingAgentThread();

    await c.openChatWithConfig(assistantConfig());
    PupauChatController.clearLivingAgentSession();
    await c.openChatWithConfig(livingAgentConfig());

    expect(c.messages, isEmpty);
  });
}
