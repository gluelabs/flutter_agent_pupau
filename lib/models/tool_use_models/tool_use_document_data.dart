import 'dart:convert';
import 'package:flutter_agent_pupau/models/attachment_model.dart';

class ToolUseDocumentData {
  List<DocumentData> documents;
  String? action;

  ToolUseDocumentData({required this.documents, this.action});

  factory ToolUseDocumentData.fromJson(
      Map<String, dynamic> json, Map<String, dynamic>? jsonTypeDetails) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    String? action = jsonTypeDetails?["toolArgs"]?["action"];
    if (firstInfo.isEmpty) return ToolUseDocumentData(documents: []);
    List<DocumentData> documents =
        DocumentData.documentsDatafromJson(jsonEncode(firstInfo["documents"]));
    return ToolUseDocumentData(documents: documents, action: action);
  }
}


class DocumentData {
  String id;
  String fileName;
  String? exportUrl;
  //Frontend only
  Attachment? relatedAttachment;

  DocumentData({
    required this.id,
    required this.fileName,
    this.exportUrl,
  });

  static List<DocumentData> documentsDatafromJson(String str) =>
      List<DocumentData>.from(
          json.decode(str).map((x) => DocumentData.fromJson(x)));

  factory DocumentData.fromJson(Map<String, dynamic> json) => DocumentData(
      id: json["id"] ?? "",
      fileName: json["fileName"] ?? "",
      exportUrl: json["exportUrl"]);
}

