class ChatImage {
  final String value;
  final ImageType type;

  ChatImage({required this.value, required this.type});
}

enum ImageType { url, base64 }
