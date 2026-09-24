import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PupauChatController outlives the chat page that created it — ChatBinding
/// reuses it whenever it is already registered — so everything agent-shaped on
/// it survives into the NEXT chat unless something clears it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // openChatWithConfig syncs the user profile, which reaches storage.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final String channel in const <String>[
      'xyz.luan/audioplayers.global',
      'xyz.luan/audioplayers',
      // resetChatState stops any TTS playback on its way through.
      'flutter_tts',
    ]) {
      messenger.setMockMethodCallHandler(
        MethodChannel(channel),
        (MethodCall call) async => null,
      );
    }
  });

  Assistant previousAgent() => Assistant(
    id: 'CEVzt',
    name: 'Marketing Assistant',
    description: '',
    imageUuid: 'avatar-uuid',
    welcomeMessage: 'Hi from the previous agent',
    customActions: const [],
    type: AssistantType.assistant,
    replyMode: ReplyMode.open,
  );

  test('opening a Living Agent drops the previous agent from the header', () {
    final PupauChatController c = PupauChatController(
      config: PupauConfig.createWithToken(
        bearerToken: 'test-token',
        assistantId: 'CEVzt',
      ),
    );
    c.assistant.value = previousAgent();

    // Deliberately NOT awaited: the point is what the header reads on the very
    // first frame, before any network call could have resolved.
    c.openChatWithConfig(
      PupauConfig.createWithToken(
        bearerToken: 'test-token',
        assistantId: 'etILjI',
        agentMode: PupauAgentMode.livingAgent,
      ),
    );

    // The app bar skeletonizes on null; anything non-null here is the previous
    // agent's name and avatar rendered inside the Living Agent chat.
    expect(c.assistant.value, isNull);
    expect(c.effectiveWelcomeMessage, isEmpty);
  });

  test('settings with no usageSettings reset the composer, not inherit it', () {
    final PupauChatController c = PupauChatController(
      config: PupauConfig.createWithToken(
        bearerToken: 'test-token',
        assistantId: 'etILjI',
        agentMode: PupauAgentMode.livingAgent,
      ),
    );
    // State left behind by a previous, more capable assistant.
    c.isAttachmentAvailable.value = true;
    c.isWebSearchAvailable.value = true;
    c.isMentionAvailable.value = true;

    // A Living Agent carries no usageSettings at all.
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
    expect(c.assistant.value?.usageSettings, isNull);

    c.setAssistantSettings();

    expect(c.isAttachmentAvailable.value, isFalse);
    expect(c.isWebSearchAvailable.value, isFalse);
    expect(c.isMentionAvailable.value, isFalse);
  });
}
