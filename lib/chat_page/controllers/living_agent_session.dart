import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';

/// A frozen Living Agent chat, kept while another agent uses the controller.
///
/// `PupauChatController` is a single instance shared by all three agent modes:
/// opening an assistant reconfigures it and `resetChatState` wipes the
/// conversation, so a Living Agent thread used to be gone — and refetched from
/// scratch — every time the user visited the assistants or marketplace
/// sections. A genuinely separate instance is not available: `GetView.tag` is
/// a `final` field (70 widgets resolve the controller through it), GetX's
/// `_insert` refuses to overwrite a live registration, and `Get.delete`
/// disposes the scroll/text controllers, which cannot be revived. So the
/// session is snapshotted instead.
///
/// Only settled state is kept. A turn still streaming when the user leaves is
/// deliberately NOT frozen: the run continues on the server, and the correct
/// way back is the transcript's `runState`/`resumeEventId` reattach, not a
/// replayed half-answer.
class LivingAgentSession {
  /// Which agent this belongs to. A restore is only valid for the same id —
  /// there is one Living Agent per account, but the check keeps a stale
  /// snapshot from surfacing under a different one.
  final String agentId;

  final Assistant? assistant;
  final PupauConversation? conversation;
  final List<PupauMessage> messages;
  final Map<String, SkillLoadedInfo> activeSkills;

  final bool historyLoaded;
  final bool isLastPage;
  final int page;
  final int itemsLoaded;
  final bool isFirstMessage;

  const LivingAgentSession({
    required this.agentId,
    required this.assistant,
    required this.conversation,
    required this.messages,
    required this.activeSkills,
    required this.historyLoaded,
    required this.isLastPage,
    required this.page,
    required this.itemsLoaded,
    required this.isFirstMessage,
  });

  /// Whether this snapshot can stand in for opening [agentId].
  ///
  /// An empty thread is not worth restoring: it would only suppress the normal
  /// first load without showing the user anything.
  bool canRestoreFor(String agentId) =>
      this.agentId.isNotEmpty && this.agentId == agentId && messages.isNotEmpty;
}
