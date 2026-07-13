import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';

/// Rebuilds in-memory active skill map from chat history (latest snapshot).
class SkillsService {

  /// Fills [out] from the newest agent message that includes [skillsLoaded].
  ///
  /// If no snapshot is found, falls back to replaying skill event messages
  /// (e.g. when a skill was just loaded and no subsequent LLM response exists).
  static void applyLatestSnapshotFromMessages(
    List<PupauMessage> messages,
    Map<String, SkillLoadedInfo> out,
  ) {
    out.clear();
    // messages is newest-first; the first snapshot found is the most recent.
    for (final PupauMessage message in messages) {
      if (message.isMessageFromAssistant && message.skillsLoaded.isNotEmpty) {
        for (final SkillLoadedInfo skill in message.skillsLoaded) {
          if (skill.hashId.isNotEmpty) {
            out[skill.hashId] = skill;
          }
        }
        return;
      }
    }
    // No snapshot found — replay skill event messages in chronological order.
    for (final PupauMessage message in messages.reversed) {
      final SkillEventDetail? detail = message.skillEventDetail;
      if (detail == null) continue;
      if (detail.isUnload) {
        out.remove(detail.info.hashId);
      } else if (detail.info.hashId.isNotEmpty) {
        out[detail.info.hashId] = detail.info;
      }
    }
  }
}
