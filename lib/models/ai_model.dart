import 'dart:convert';

List<AiModel> aiModelsFromJson(String str) =>
    List<AiModel>.from(json.decode(str).map((x) => AiModel.fromJson(x)));

AiModel aiModelFromJson(String str) => AiModel.fromJson(json.decode(str));

class AiModel {
  String id;
  String aiVendorId;
  String name;
  String cost;
  String includedK;
  String costExtraK;
  bool frontier;
  bool legacy;
  bool canUseTools;
  List<String> capabilities;
  AiVendor? vendor;


  AiModel({
    required this.id,
    required this.aiVendorId,
    required this.name,
    required this.cost,
    required this.includedK,
    required this.costExtraK,
    required this.frontier,
    required this.legacy,
    required this.canUseTools,
    required this.capabilities,
    required this.vendor,
  });

  factory AiModel.fromJson(Map<String, dynamic> json) => AiModel(
        id: json["id"] ?? "",
        aiVendorId: json["aiVendorId"] ?? "",
        name: json["name"] ?? "",
        cost: json["cost"] ?? "",
        includedK: json["includedK"] ?? "",
        costExtraK: json["costExtraK"] ?? "",
        frontier: json["frontier"] ?? false,
        legacy: json["legacy"] ?? false,
        canUseTools: json["functionCalling"] ?? false,
        capabilities: json["capabilities"] != null
            ? (json["capabilities"] is List
                ? List<String>.from(
                    (json["capabilities"] as List)
                        .where((x) => x != null)
                        .map((x) => x.toString()))
                : [])
            : [],
        vendor:
            json["vendor"] != null ? AiVendor.fromJson(json["vendor"]) : null,
      
      );
}


class AiVendor {
  String id;
  String name;
  String description;
  String logo;

  AiVendor({
    required this.id,
    required this.name,
    required this.description,
    required this.logo,
  });

  factory AiVendor.fromJson(Map<String, dynamic> json) => AiVendor(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        description: json["description"] ?? "",
        logo: json["logo"] ?? "",
      );
}