import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ToolUseHeartbeatData {
  final String toolSessionId;
  final String toolName;
  final int elapsedMs;
  final ToolUseType toolUseType;

  ToolUseHeartbeatData({
    required this.toolSessionId,
    required this.toolName,
    required this.elapsedMs,
    required this.toolUseType,
  });

  factory ToolUseHeartbeatData.fromJson(Map<String, dynamic> json) {
    final String actorType = getString(json['actorType']);
    return ToolUseHeartbeatData(
      toolSessionId: getString(json['toolSessionId']),
      toolName: getString(json['toolName']),
      elapsedMs: getInt(json['elapsedMs']),
      toolUseType: ToolUseService.getToolUseTypeEnumFlat(actorType),
    );
  }
}

