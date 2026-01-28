import 'dart:convert';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Web-specific implementation for file downloads
class FileServiceWeb {
  /// Saves content to downloads on web by triggering a browser download
  static Future<bool> saveToDownloadsWeb(
    String content,
    String fileName,
    String extension,
  ) async {
    try {
      // Create the full filename with extension
      final String fullFileName = '$fileName.$extension';
      
      // Convert content to bytes
      final bytes = utf8.encode(content);
      
      // Create a Blob from the content
      final blob = web.Blob([bytes.toJS].toJS);
      
      // Create an object URL for the blob
      final url = web.URL.createObjectURL(blob);
      
      // Create a temporary anchor element
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = fullFileName
        ..style.display = 'none';
      
      // Add to document, click, and remove
      web.document.body?.appendChild(anchor);
      anchor.click();
      web.document.body?.removeChild(anchor);
      
      // Revoke the object URL to free up memory
      web.URL.revokeObjectURL(url);
      
      return true;
    } catch (e) {
      return false;
    }
  }
}
