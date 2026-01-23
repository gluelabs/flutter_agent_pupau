import 'dart:io';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class TtsService {
  FlutterTts textToSpeach = FlutterTts();

  Future<void> initTextToSpeach() async {
    textToSpeach.stop();
    String localeLanguage = Platform.localeName.replaceAll("_", "-");
    if (await textToSpeach.isLanguageAvailable(localeLanguage)) {
      textToSpeach.setLanguage(localeLanguage);
    }
  }

  Future<void> startReading(PupauMessage message, List<PupauMessage> messages,
      ChatController chatController) async {
    textToSpeach.stop();
    for (PupauMessage chatMessage in messages) {
      chatMessage.isNarrating = false;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    message.isNarrating = false; //Reset to false to refresh the UI
    chatController.messages.refresh();
    chatController.update();
    message.isNarrating = true;
    chatController.messages.refresh();
    chatController.update();
    textToSpeach.awaitSpeakCompletion(true);
    await textToSpeach.speak(message.answer);
    message.isNarrating = false;
    chatController.messages.refresh();
    chatController.update();
  }

  void stopReadingMessage(PupauMessage message, ChatController chatController) {
    message.isNarrating = false;
    textToSpeach.stop();
    chatController.messages.refresh();
    chatController.update();
  }

  void stopReading() => textToSpeach.stop();
}
