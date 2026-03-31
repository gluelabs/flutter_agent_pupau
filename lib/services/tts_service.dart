import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/language_service.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class TtsService {
  FlutterTts textToSpeach = FlutterTts();

  Future<void> initTextToSpeach({PupauConfig? config}) async {
    textToSpeach.stop();
    
    String localeLanguage;
    
    // Use language from config if available
    if (config != null) {
      localeLanguage = LanguageService.getCodeExtended(config.language);
    } else {
      // Fallback to platform locale
      if(!kIsWeb) {
        localeLanguage = Platform.localeName.replaceAll("_", "-");
      } else {
        localeLanguage = "en-US";
      }
    }
    
    if (await textToSpeach.isLanguageAvailable(localeLanguage)) {
      textToSpeach.setLanguage(localeLanguage);
    }
  }

  Future<void> startReading(PupauMessage message, List<PupauMessage> messages,
      PupauChatController chatController) async {
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

  void stopReadingMessage(PupauMessage message, PupauChatController chatController) {
    message.isNarrating = false;
    textToSpeach.stop();
    chatController.messages.refresh();
    chatController.update();
  }

  void stopReading() => textToSpeach.stop();
}
