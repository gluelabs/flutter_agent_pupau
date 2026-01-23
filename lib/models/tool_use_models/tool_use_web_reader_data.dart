class ToolUseWebReaderData {
  String url;

  ToolUseWebReaderData({
    required this.url
  });

  factory ToolUseWebReaderData.fromJson(Map<String, dynamic> json) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    if (firstInfo.isEmpty) return ToolUseWebReaderData(url: "");
    String url = firstInfo["url"] ?? "";
    return ToolUseWebReaderData(
        url: url);
  }
}