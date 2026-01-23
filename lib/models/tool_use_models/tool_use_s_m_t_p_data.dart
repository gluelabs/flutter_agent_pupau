class ToolUseSMTPData {
  String? subject;
  String? body;
  String? to;
  String? cc;
  String? bcc;

  ToolUseSMTPData(
      {required this.subject,
      required this.body,
      required this.to,
      required this.cc,
      required this.bcc});

  factory ToolUseSMTPData.fromJson(Map<String, dynamic> json) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    if (firstInfo.isEmpty) {
      return ToolUseSMTPData(subject: "", body: "", to: "", cc: "", bcc: "");
    }
    return ToolUseSMTPData(
        subject: firstInfo["subject"] ?? "",
        body: firstInfo["body"] ?? "",
        to: firstInfo["to"] ?? "",
        cc: firstInfo["cc"] ?? "",
        bcc: firstInfo["bcc"] ?? "");
  }
}
