class ToolUsePipelineData {
  String actorId;
  String message;
  List<String> info;
  List<String> errors;

  ToolUsePipelineData({
    required this.actorId,
    required this.message,
    required this.info,
    required this.errors,
  });

  factory ToolUsePipelineData.fromJson(Map<String, dynamic> json) =>
      ToolUsePipelineData(
        actorId: json["actorId"] ?? "",
        message: json["message"] ?? "",
        info: json["info"] is List<String> ? json["info"] : [],
        errors: json["errors"] is List<String> ? json["errors"] : [],
      );

  Map<String, dynamic> toJson() => {
        "actorId": actorId,
        "message": message,
        "info": info,
        "errors": errors,
      };
}

