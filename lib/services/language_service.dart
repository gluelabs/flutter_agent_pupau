import 'package:flutter_agent_pupau/config/pupau_config.dart';

/// Service for language code conversions
class LanguageService {
  /// Returns the 2-letter language code (e.g., 'en', 'de', 'es').
  static String getCode(PupauLanguage language) {
    switch (language) {
      case PupauLanguage.en:
        return 'en';
      case PupauLanguage.de:
        return 'de';
      case PupauLanguage.es:
        return 'es';
      case PupauLanguage.fr:
        return 'fr';
      case PupauLanguage.hi:
        return 'hi';
      case PupauLanguage.it:
        return 'it';
      case PupauLanguage.ko:
        return 'ko';
      case PupauLanguage.nl:
        return 'nl';
      case PupauLanguage.pl:
        return 'pl';
      case PupauLanguage.pt:
        return 'pt';
      case PupauLanguage.sq:
        return 'sq';
      case PupauLanguage.sv:
        return 'sv';
      case PupauLanguage.tr:
        return 'tr';
      case PupauLanguage.zh:
        return 'zh';
    }
  }

  /// Returns the extended locale code with country (e.g., 'en-US', 'it-IT', 'de-DE').
  static String getCodeExtended(PupauLanguage language) {
    switch (language) {
      case PupauLanguage.en:
        return 'en-US';
      case PupauLanguage.de:
        return 'de-DE';
      case PupauLanguage.es:
        return 'es-ES';
      case PupauLanguage.fr:
        return 'fr-FR';
      case PupauLanguage.hi:
        return 'hi-IN';
      case PupauLanguage.it:
        return 'it-IT';
      case PupauLanguage.ko:
        return 'ko-KR';
      case PupauLanguage.nl:
        return 'nl-NL';
      case PupauLanguage.pl:
        return 'pl-PL';
      case PupauLanguage.pt:
        return 'pt-PT';
      case PupauLanguage.sq:
        return 'sq-AL';
      case PupauLanguage.sv:
        return 'sv-SE';
      case PupauLanguage.tr:
        return 'tr-TR';
      case PupauLanguage.zh:
        return 'zh-CN';
    }
  }
}
