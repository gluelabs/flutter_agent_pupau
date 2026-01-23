import 'package:google_sign_in/google_sign_in.dart';

class GoogleDriveService {
  static GoogleSignIn googleSignIn = GoogleSignIn.instance;

  static Future<String?> requestGoogleDriveAuth() async {
    try {
      List<String> scopes = [
        'openid',
        'email',
        'profile',
        'https://www.googleapis.com/auth/drive'
      ];
      GoogleSignInAccount user =
          await googleSignIn.authenticate(scopeHint: scopes);
      GoogleSignInServerAuthorization? serverAuth =
          await user.authorizationClient.authorizeServer(scopes);
      return serverAuth?.serverAuthCode;
    } catch (e) {
      return null;
    }
  }
}
