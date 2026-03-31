import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ToolUseArgsDeltaData {
  final String id;
  final String toolId;
  final String toolName;
  final int toolIndex;
  final String argsDelta;
  final ToolUseType toolUseType;

  ToolUseArgsDeltaData({
    required this.id,
    required this.toolId,
    required this.toolName,
    required this.toolIndex,
    required this.argsDelta,
    required this.toolUseType,
  });

  factory ToolUseArgsDeltaData.fromJson(Map<String, dynamic> json) {
    final String actorType = getString(json['actorType']);
    return ToolUseArgsDeltaData(
      id: getString(json['id']),
      toolId: getString(json['toolId']),
      toolName: getString(json['toolName']),
      toolIndex: getInt(json['toolIndex']),
      argsDelta: getString(json['argsDelta']),
      toolUseType: ToolUseService.getToolUseTypeEnumFlat(actorType),
    );
  }
}

class ToolArgsDeltaComputation {
  final String fullBuffer;
  final String? preview;
  final String? title;
  final int size;

  const ToolArgsDeltaComputation({
    required this.fullBuffer,
    required this.preview,
    required this.title,
    required this.size,
  });
}
