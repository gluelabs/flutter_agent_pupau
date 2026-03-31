import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ToolUsePendingData {
  final String id;
  final String toolName;
  final String toolSessionId;
  final ToolUseType toolUseType;

  ToolUsePendingData({
    required this.id,
    required this.toolName,
    required this.toolSessionId,
    required this.toolUseType,
  });

  factory ToolUsePendingData.fromJson(Map<String, dynamic> json) {
    final String actorType = getString(json['actorType']);
    return ToolUsePendingData(
      id: getString(json['id']),
      toolName: getString(json['toolName']),
      toolSessionId: getString(json['toolSessionId']),
      toolUseType: ToolUseService.getToolUseTypeEnumFlat(actorType),
    );
  }
}

