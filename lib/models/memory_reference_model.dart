import 'package:flutter_agent_pupau/services/json_parse_service.dart';

enum MemoryReferenceSource {
  user,
  agent,
  system,
}

extension MemoryReferenceSourceParsing on MemoryReferenceSource {
  static MemoryReferenceSource fromApiValue(String? value) {
    final String normalized = (value ?? '').trim().toUpperCase();
    switch (normalized) {
      case 'USER':
        return MemoryReferenceSource.user;
      case 'AGENT':
        return MemoryReferenceSource.agent;
      case 'SYSTEM':
        return MemoryReferenceSource.system;
      default:
        return MemoryReferenceSource.system;
    }
  }
}

class MemoryReference {
  final String memoryId;
  final String content;
  final double similarity;
  final String priority; // 'ALWAYS' | 'NORMAL'
  final String? category;
  final MemoryReferenceSource source;
  final DateTime? validFrom;

  MemoryReference({
    required this.memoryId,
    required this.content,
    required this.similarity,
    required this.priority,
    this.source = MemoryReferenceSource.system,
    this.category,
    this.validFrom,
  });

  factory MemoryReference.fromMap(Map<String, dynamic> json) =>
      MemoryReference(
        memoryId: getString(json["memoryId"]),
        content: getString(json["content"]),
        similarity: getDouble(json["similarity"]),
        priority: getString(json["priority"]),
        category: json["category"] == null ? null : getString(json["category"]),
        source: MemoryReferenceSourceParsing.fromApiValue(
          getString(json["source"]),
        ),
        validFrom:
            json["validFrom"] == null ? null : DateTime.tryParse(getString(json["validFrom"])),
      );
}
