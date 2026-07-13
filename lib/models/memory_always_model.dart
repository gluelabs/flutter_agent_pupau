import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class MemoryAlways {
  final String memoryId;
  final String content;
  final String priority; // 'ALWAYS'
  final String? category;

  MemoryAlways({
    required this.memoryId,
    required this.content,
    required this.priority,
    this.category,
  });

  factory MemoryAlways.fromMap(Map<String, dynamic> json) => MemoryAlways(
        memoryId: getString(json["memoryId"]),
        content: getString(json["content"]),
        priority: getString(json["priority"]),
        category: json["category"] == null ? null : getString(json["category"]),
      );
}

