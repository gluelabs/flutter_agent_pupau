class ToolUseKnowledgeBaseData {
  String kbId;
  String type;
  String data;
  String pageNumber;

  ToolUseKnowledgeBaseData({
    required this.kbId,
    required this.type,
    required this.data,
    required this.pageNumber,
  });
  factory ToolUseKnowledgeBaseData.fromJson(Map<String, dynamic> json) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    if (firstInfo.isEmpty) {
      return ToolUseKnowledgeBaseData(
          kbId: "", type: "", data: "", pageNumber: "");
    }
    return ToolUseKnowledgeBaseData(
      kbId: firstInfo["kbId"] ?? "",
      type: firstInfo["type"] ?? "",
      data: firstInfo["data"] ?? "",
      pageNumber: firstInfo["pageNumber"] ?? "",
    );
  }
}
