import 'dart:convert';
import 'package:flutter_agent_pupau/models/user_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';

/// Pupau user profile. [syncUserProfileIfBearerChanged] limits fetches to once
/// per bearer token per app process unless the token changes.
class UserService {
  /// Last bearer token for which [getProfile] completed successfully this process.
  static String? _lastBearerTokenProfileSynced;

  /// Fetches profile when [bearerToken] is non-empty and either this is the first
  /// time we see this token in the current app session or the token changed from
  /// the last successful sync. Skips duplicate calls for the same token until the
  /// next app restart (in-memory only).
  static Future<void> syncUserProfileIfBearerChanged(String bearerToken) async {
    final String token = bearerToken.trim();
    if (token.isEmpty) return;
    if (_lastBearerTokenProfileSynced == token) return;
    final User? user = await getProfile();
    if (user != null) {
      _lastBearerTokenProfileSynced = token;
    }
  }

  /// Get Pupau user profile
  /// Used for [USER_NAME] placeholder tag replacement
  static Future<User?> getProfile() async {
    await PupauSharedPreferences.init();
    User? user;
    await ApiService.call(
      ApiUrls.profileUrl,
      RequestType.get,
      onSuccess: (response) async {
        user = userFromMap(jsonEncode(response.data));
        await PupauSharedPreferences.setUser(user!);
      },
    );
    return user;
  }
}
