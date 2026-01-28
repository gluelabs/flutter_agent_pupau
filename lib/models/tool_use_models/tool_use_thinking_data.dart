class ToolUseThinkingData {
  final String thought;
  final String subject;

  ToolUseThinkingData({
    required this.thought,
    required this.subject,
  });

  factory ToolUseThinkingData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? toolArgs =
        json['toolArgs'] is Map<String, dynamic>
            ? json['toolArgs'] as Map<String, dynamic>
            : null;

    return ToolUseThinkingData(
      thought: toolArgs?['thought'] ?? "",
      subject: toolArgs?['subject'] ?? "",
    );
  }
}
