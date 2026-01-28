import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class TtsService {
  FlutterTts textToSpeach = FlutterTts();

  Future<void> initTextToSpeach({PupauConfig? config}) async {
    textToSpeach.stop();
    
    String localeLanguage;
    
    // Use language from config if available
    if (config?.language != null && config!.language!.isNotEmpty) {
      localeLanguage = _convertLanguageCodeToLocale(config.language!);
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
  
  /// Converts a 2-letter language code to a full locale string
  String _convertLanguageCodeToLocale(String languageCode) {
    final String lowerCode = languageCode.toLowerCase();
    
    // Map of language codes to their default locales
    final Map<String, String> languageToLocale = {
      'en': 'en-US',
      'it': 'it-IT',
      'de': 'de-DE',
      'fr': 'fr-FR',
      'es': 'es-ES',
      'hi': 'hi-IN',
      'ko': 'ko-KR',
      'nl': 'nl-NL',
      'pl': 'pl-PL',
      'pt': 'pt-PT',
      'sq': 'sq-AL',
      'sv': 'sv-SE',
      'tr': 'tr-TR',
      'zh': 'zh-CN',
    };
    
    return languageToLocale[lowerCode] ?? '$lowerCode-${lowerCode.toUpperCase()}';
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
