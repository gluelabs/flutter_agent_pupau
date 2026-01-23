import 'package:shared_preferences/shared_preferences.dart';

class PupauSharedPreferences {
  // prevent making instance
  PupauSharedPreferences._();

  // get storage
  static late SharedPreferences _sharedPreferences;

  static const String _tutorialMessageMenuDoneKey =
      'pupau_tutorial_message_menu_done_key';
  static const String _anonymousConversationKey =
      'pupau_anonymous_conversation_key';

  /// init get storage services
  static Future<void> init() async =>
      _sharedPreferences = await SharedPreferences.getInstance();

  static void setStorage(SharedPreferences sharedPreferences) =>
      _sharedPreferences = sharedPreferences;

  static Future<void> setTutorialMessageMenuDone(bool done) =>
      _sharedPreferences.setBool(_tutorialMessageMenuDoneKey, done);

  static bool getTutorialMessageMenuDone() =>
      _sharedPreferences.getBool(_tutorialMessageMenuDoneKey) ?? false;

  static Future<void> deleteAnonymousConversationKey() =>
      _sharedPreferences.remove(_anonymousConversationKey);

  static Future<void> setAnonymousConversationKey(String key) =>
      _sharedPreferences.setString(_anonymousConversationKey, key);

  static String? getAnonymousConversationKey() =>
      _sharedPreferences.getString(_anonymousConversationKey);
}
