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
  static const String _attachmentTrimmingOpenedIdsKey =
      'pupau_attachment_trimming_opened_ids';

  static const String _lastEventIdKeyPrefix = 'pupau_last_event_id_';

  static String _lastEventIdKey(String conversationId) =>
      '$_lastEventIdKeyPrefix$conversationId';

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

  /// Returns message IDs for which the attachment trimming modal was opened at least once.
  static Set<String> getAttachmentTrimmingOpenedMessageIds() {
    final String? raw = _sharedPreferences.getString(
      _attachmentTrimmingOpenedIdsKey,
    );
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  /// Marks the attachment trimming modal as opened for [messageId].
  static Future<void> addAttachmentTrimmingOpenedMessageId(
    String messageId,
  ) async {
    final Set<String> ids = getAttachmentTrimmingOpenedMessageIds();
    if (ids.contains(messageId)) return;
    ids.add(messageId);
    await _sharedPreferences.setString(
      _attachmentTrimmingOpenedIdsKey,
      ids.join(','),
    );
  }

  /// Gets the last SSE persisted cursor (event id) for a conversation.
  ///
  /// This value is used to request an SSE history/catch-up with the server.
  static String? getLastEventId(String conversationId) =>
      _sharedPreferences.getString(_lastEventIdKey(conversationId));

  /// Persists the last SSE cursor (event id) for a conversation.
  static Future<void> setLastEventId(
    String conversationId,
    String lastEventId,
  ) async {
    if (lastEventId.trim().isEmpty) return;
    await _sharedPreferences.setString(
      _lastEventIdKey(conversationId),
      lastEventId,
    );
  }
}
