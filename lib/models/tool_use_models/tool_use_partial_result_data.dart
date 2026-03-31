import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ToolUsePartialResultData {
  final String id;
  final String toolSessionId;
  final String toolName;
  final dynamic partialData;
  final String phase;
  final String queryGroupId;
  final ToolUseType toolUseType;

  ToolUsePartialResultData({
    required this.id,
    required this.toolSessionId,
    required this.toolName,
    required this.partialData,
    required this.phase,
    required this.queryGroupId,
    required this.toolUseType,
  });

  factory ToolUsePartialResultData.fromJson(Map<String, dynamic> json) {
    final String actorType = getString(json['actorType']);
    return ToolUsePartialResultData(
      id: getString(json['id']),
      toolSessionId: getString(json['toolSessionId']),
      toolName: getString(json['toolName']),
      partialData: json['partialData'],
      phase: getString(json['phase']),
      queryGroupId: getString(json['queryGroupId']),
      toolUseType: ToolUseService.getToolUseTypeEnumFlat(actorType),
    );
  }
}

