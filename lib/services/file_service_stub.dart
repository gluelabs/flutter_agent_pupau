/// Stub implementation for non-web platforms
/// This file is imported when running on mobile/desktop platforms
class FileServiceWeb {
  /// Stub method - should never be called on non-web platforms
  static Future<bool> saveToDownloadsWeb(
    String content,
    String fileName,
    String extension,
  ) async {
    throw UnsupportedError('Web downloads are only supported on web platform');
  }
}
