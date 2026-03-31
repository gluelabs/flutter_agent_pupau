import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:get/get.dart';
import 'languages/it_it_translation.dart';
import 'languages/sq_al_translation.dart';
import 'languages/tr_tr_translation.dart';
import 'languages/es_es_translation.dart';
import 'languages/fr_fr_translation.dart';
import 'languages/pl_pl_translation.dart';
import 'languages/de_de_translation.dart';
import 'languages/ko_kr_translation.dart';
import 'languages/zh_cn_translation.dart';
import 'languages/nl_nl_translation.dart';
import 'languages/hi_in_translation.dart';
import 'languages/sv_se_translation.dart';
import 'languages/pt_pt_translation.dart';
import 'languages/en_us_translation.dart';

class LocalizationService extends Translations {
  LocalizationService._();

  static LocalizationService? _instance;

  static LocalizationService getInstance() {
    _instance ??= LocalizationService._();
    return _instance!;
  }

  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enUs,
    'it_IT': itIt,
    'sq_AL': sqAl,
    'pl_PL': plPl,
    'tr_TR': trTr,
    'es_ES': esEs,
    'fr_FR': frFr,
    'de_DE': deDe,
    'nl_NL': nlNl,
    'ko_KR': koKr,
    'zh_CN': zhCn,
    'hi_IN': hiIn,
    'pt_PT': ptPt,
    'sv_SE': svSe,
    'en': enUs,
    'it': itIt,
    'sq': sqAl,
    'pl': plPl,
    'tr': trTr,
    'es': esEs,
    'fr': frFr,
    'de': deDe,
    'nl': nlNl,
    'ko': koKr,
    'zh': zhCn,
    'hi': hiIn,
    'pt': ptPt,
    'sv': svSe,
  };

  static Language getLanguageFromConfig(PupauConfig config) {
    switch (config.language) {
      case PupauLanguage.de:
        return Language.german;
      case PupauLanguage.en:
        return Language.english;
      case PupauLanguage.es:
        return Language.spanish;
      case PupauLanguage.fr:
        return Language.french;
      case PupauLanguage.hi:
        return Language.hindi;
      case PupauLanguage.it:
        return Language.italian;
      case PupauLanguage.ko:
        return Language.korean;
      case PupauLanguage.nl:
        return Language.dutch;
      case PupauLanguage.pl:
        return Language.polish;
      case PupauLanguage.pt:
        return Language.portuguese;
      case PupauLanguage.sq:
        return Language.albanian;
      case PupauLanguage.sv:
        return Language.swedish;
      case PupauLanguage.tr:
        return Language.turkish;
      case PupauLanguage.zh:
        return Language.chinese;
    }
  }

  static Locale getLocaleFromLanguage(Language language) {
    switch (language) {
      case Language.italian:
        return const Locale("it", "IT");
      case Language.albanian:
        return const Locale("sq", "AL");
      case Language.polish:
        return const Locale("pl", "PL");
      case Language.turkish:
        return const Locale("tr", "TR");
      case Language.spanish:
        return const Locale("es", "ES");
      case Language.french:
        return const Locale("fr", "FR");
      case Language.german:
        return const Locale("de", "DE");
      case Language.dutch:
        return const Locale("nl", "NL");
      case Language.korean:
        return const Locale("ko", "KR");
      case Language.chinese:
        return const Locale("zh", "CN");
      case Language.hindi:
        return const Locale("hi", "IN");
      case Language.portuguese:
        return const Locale("pt", "PT");
      case Language.swedish:
        return const Locale("sv", "SE");
      case Language.english:
        return const Locale("en", "US");
    }
  }

  /// Get locale directly from config language
  /// Returns the locale for the language specified in config
  static Locale getLocaleFromConfig(PupauConfig config) {
    final language = getLanguageFromConfig(config);
    return getLocaleFromLanguage(language);
  }

  static DateLocale getDateLocale(Language language) {
    switch (language) {
      case Language.italian:
        return const ItalianDateLocale();
      case Language.chinese:
        return const SimplifiedChineseDateLocale();
      case Language.french:
        return const FrenchDateLocale();
      case Language.german:
        return const GermanDateLocale();
      case Language.korean:
        return const KoreanDateLocale();
      case Language.spanish:
        return const SpanishDateLocale();
      case Language.turkish:
        return const TurkishDateLocale();
      case Language.portuguese:
        return const PortugueseDateLocale();
      default:
        return const EnglishDateLocale();
    }
  }
}

enum Language {
  english,
  italian,
  albanian,
  spanish,
  french,
  polish,
  german,
  dutch,
  turkish,
  korean,
  chinese,
  hindi,
  portuguese,
  swedish,
}
