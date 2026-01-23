import 'dart:convert';

import 'package:flutter_agent_pupau/services/json_parse_service.dart';

List<Attachment> attachmentsFromMap(String str) =>
    List<Attachment>.from(json.decode(str).map((x) => Attachment.fromMap(x)));

class Attachment {
  String id;
  String conversationId;
  String companyId;
  String userId;
  String previousQueryId;
  String type;
  String fileName;
  String link;
  String extension;
  String ragId;
  bool summary;
  int tokens;
  //Frontend
  bool active = true;
  bool isShown = false;
  bool isLoadingContent = false;

  Attachment({
    required this.id,
    required this.conversationId,
    required this.companyId,
    required this.userId,
    required this.previousQueryId,
    required this.type,
    required this.fileName,
    required this.link,
    required this.extension,
    required this.ragId,
    required this.summary,
    required this.tokens,
  });

  factory Attachment.fromMap(Map<String, dynamic> json) => Attachment(
        id: getString(json["id"]),
        conversationId: getString(json["conversationId"]),
        companyId: getString(json["companyId"]),
        userId: getString(json["userId"]),
        previousQueryId: getString(json["previousQueryId"]),
        type: getString(json["type"]),
        fileName: getString(json["fileName"]),
        link: getString(json["link"]),
        extension: getString(json["extension"]),
        ragId: getString(json["ragId"]),
        summary: getBool(json["summary"]),
        tokens: getInt(json["tokenCount"]),
      );
}
