import 'dart:convert';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

/// One skill listed in query [extraInfo.skillsLoaded] (history) or SSE skill events.
class SkillLoadedInfo {
  final String hashId;
  final String name;
  final SkillLoaderType loadedBy;

  const SkillLoadedInfo({
    required this.hashId,
    required this.name,
    required this.loadedBy,
  });

  factory SkillLoadedInfo.fromJson(dynamic json) {
    if (json is! Map) {
      return const SkillLoadedInfo(hashId: '', name: '', loadedBy: SkillLoaderType.agent);
    }
    final Map<String, dynamic> mapData = Map<String, dynamic>.from(json);
    return SkillLoadedInfo(
      hashId: getString(mapData['hashId']),
      name: getString(mapData['name']),
      loadedBy: getLoaderType(getString(mapData['loadedBy'])),
    );
  }

  static SkillLoaderType getLoaderType(String loadedBy) {
    if (loadedBy.isEmpty) return SkillLoaderType.agent;
    switch (loadedBy.toLowerCase().trim()) {
      case 'user':
        return SkillLoaderType.user;
      default:
        return SkillLoaderType.agent;
    }
  }
}

/// Parsed SKILL_LOADED / SKILL_UNLOADED SSE row (drives compact bubble UI).
class SkillEventDetail {
  final SkillLoadedInfo info;
  final bool isUnload;

  const SkillEventDetail({required this.info, required this.isUnload});

  /// Raw SSE/JSON: `skillHashId`, `skillName`, `loadedBy`.
  static SkillEventDetail? fromSsePayload(
    Map<String, dynamic> json, {
    required bool isUnload,
  }) {
    final String hashId = getString(json['skillHashId']);
    final String name = getString(json['skillName']);
    if (hashId.isEmpty || name.isEmpty) return null;
    return SkillEventDetail(
      info: SkillLoadedInfo(
        hashId: hashId,
        name: name,
        loadedBy: SkillLoadedInfo.getLoaderType(getString(json['loadedBy'] ?? '')),
      ),
      isUnload: isUnload,
    );
  }

  /// Parses from a `TOOL_USE_START` SSE event where `typeDetails.toolName` is
  /// `skill_load` / `skill_unload` and `typeDetails.nativeTool.id` is `SKILL`.
  ///
  /// Reads `typeDetails.toolId` as hashId and `typeDetails.toolArgs.skillName`
  /// as the human-readable skill name.
  static SkillEventDetail? fromToolUseStartPayload(
    Map<String, dynamic> json, {
    required bool isUnload,
  }) {
    final dynamic typeDetails = json['typeDetails'];
    if (typeDetails is! Map) return null;
    final String hashId = getString(typeDetails['toolId']);
    if (hashId.isEmpty) return null;
    final dynamic toolArgs = typeDetails['toolArgs'];
    final String skillName =
        toolArgs is Map ? getString(toolArgs['skillName']) : '';
    return SkillEventDetail(
      info: SkillLoadedInfo(
        hashId: hashId,
        name: skillName,
        loadedBy: SkillLoaderType.agent,
      ),
      isUnload: isUnload,
    );
  }

  /// Parses from a history item whose `extraInfo.typeDetails.nativeTool.id == "SKILL"`.
  ///
  /// Prefers `info[0]` in the answer JSON (has the hashId); falls back to
  /// `toolArgs.skillName` with a synthetic hashId when the answer is unavailable.
  static SkillEventDetail? fromHistoryNativeToolItem(Map<String, dynamic> json) {
    try {
      final dynamic typeDetails = json['extraInfo']?['typeDetails'];
      if (typeDetails == null) return null;
      final String toolName = (typeDetails['toolName']?.toString() ?? '').trim();
      final bool isUnload = toolName == 'skill_unload';

      // Best source: answer JSON contains info[0] with skillHashId + skillName.
      final String answerStr = (json['answer']?.toString() ?? '').trim();
      if (answerStr.isNotEmpty) {
        try {
          final dynamic decoded = jsonDecode(answerStr);
          if (decoded is Map) {
            final dynamic infoList = decoded['info'];
            if (infoList is List && infoList.isNotEmpty) {
              final dynamic first = infoList[0];
              if (first is Map) {
                final String hashId = getString(first['skillHashId']);
                final String name = getString(first['skillName']);
                if (hashId.isNotEmpty && name.isNotEmpty) {
                  return SkillEventDetail(
                    info: SkillLoadedInfo(
                      hashId: hashId,
                      name: name,
                      loadedBy: SkillLoadedInfo.getLoaderType(
                        getString(first['loadedBy'] ?? ''),
                      ),
                    ),
                    isUnload: isUnload,
                  );
                }
              }
            }
          }
        } catch (_) {}
      }

      // Fallback: use toolArgs.skillName with a synthetic hashId.
      final dynamic toolArgs = typeDetails['toolArgs'];
      if (toolArgs is Map) {
        final String skillName = getString(toolArgs['skillName']);
        if (skillName.isNotEmpty) {
          final String fallbackHashId =
              'hist_${skillName}_${json["id"] ?? DateTime.now().microsecondsSinceEpoch}';
          return SkillEventDetail(
            info: SkillLoadedInfo(
              hashId: fallbackHashId,
              name: skillName,
              loadedBy: SkillLoaderType.agent,
            ),
            isUnload: isUnload,
          );
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

enum SkillLoaderType {
  agent,
  user,
}
