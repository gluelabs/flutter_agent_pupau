import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// Response payload for native tool `subagent_spawn` (actor SUBAGENT).
/// See `info[0].status`: `accepted` (async), `completed` / `error` (sync).
class ToolUseSubagentData {
  final String message;
  final List<SubagentSpawnInfo> info;
  final List<String> errors;

  ToolUseSubagentData({
    required this.message,
    required this.info,
    required this.errors,
  });

  factory ToolUseSubagentData.fromNativeMap(Map<String, dynamic> map) {
    final List<SubagentSpawnInfo> infos = [];
    final dynamic rawInfo = map['info'];
    if (rawInfo is List) {
      for (final dynamic e in rawInfo) {
        if (e is Map<String, dynamic>) {
          infos.add(SubagentSpawnInfo.fromJson(e));
        } else if (e is Map) {
          infos.add(SubagentSpawnInfo.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    List<String> errs = [];
    final dynamic rawErrors = map['errors'];
    if (rawErrors is List) {
      errs = rawErrors.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return ToolUseSubagentData(
      message: map['message']?.toString() ?? '',
      info: infos,
      errors: errs,
    );
  }

  /// First spawn info block, if any.
  SubagentSpawnInfo? get firstInfo => info.isEmpty ? null : info.first;
}

class SubagentSpawnInfo {
  final SubagentSpawnStatus status;
  final int runId;
  final String? childConversationId;
  final String? childConversationHashId;
  final String? mode;
  final String? note;
  final SubagentOutcomeStatus? outcomeStatus;
  final String? error;

  SubagentSpawnInfo({
    required this.status,
    required this.runId,
    this.childConversationId,
    this.childConversationHashId,
    this.mode,
    this.note,
    this.outcomeStatus,
    this.error,
  });

  factory SubagentSpawnInfo.fromJson(Map<String, dynamic> json) {
    final dynamic outcome = json['outcome'];
    SubagentOutcomeStatus? outcomeStatus;
    if (outcome is Map) {
      final String? status = outcome['status']?.toString();
      outcomeStatus = SubagentOutcomeStatus.fromString(status);
    }
    return SubagentSpawnInfo(
      status: SubagentSpawnStatus.fromString(json['status']?.toString()),
      runId: getInt(json['runId']),
      childConversationId: json['childConversationId'] != null
          ? getString(json['childConversationId'])
          : null,
      childConversationHashId: json['childConversationHashId']?.toString(),
      mode: json['mode']?.toString(),
      note: json['note']?.toString(),
      outcomeStatus: outcomeStatus,
      error: json['error']?.toString(),
    );
  }
}

enum SubagentSpawnStatus {
  accepted,
  completed,
  error,
  unknown;

  static SubagentSpawnStatus fromString(String? s) {
    switch (s) {
      case 'accepted':
        return SubagentSpawnStatus.accepted;
      case 'completed':
        return SubagentSpawnStatus.completed;
      case 'error':
        return SubagentSpawnStatus.error;
      default:
        return SubagentSpawnStatus.unknown;
    }
  }
}

enum SubagentOutcomeStatus {
  ok,
  error,
  timeout,
  killed,
  unknown;

  static SubagentOutcomeStatus? fromString(String? status) {
    if (status == null) return null;
    switch (status.toLowerCase().trim()) {
      case 'ok':
        return SubagentOutcomeStatus.ok;
      case 'error':
        return SubagentOutcomeStatus.error;
      case 'timeout':
        return SubagentOutcomeStatus.timeout;
      case 'killed':
        return SubagentOutcomeStatus.killed;
      case 'unknown':
        return SubagentOutcomeStatus.unknown;
      default:
        return null;
    }
  }
}
