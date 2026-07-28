import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:get/get.dart';

/// Storage order is newest-first ([PupauChatController.messages] uses
/// [List.insert] at 0). This returns oldest → newest for UI walk top → bottom.
List<PupauMessage> messagesOldestToNewest(List<PupauMessage> messages) =>
    List<PupauMessage>.from(messages.reversed);

/// Non-empty [PupauMessage.groupId] only; each list is oldest → newest.
Map<String, List<PupauMessage>> groupMessagesByGroupId(
  List<PupauMessage> messages,
) {
  final Map<String, List<PupauMessage>> groups = <String, List<PupauMessage>>{};
  for (final PupauMessage message in messages) {
    final String gid = message.groupId.trim();
    if (gid.isEmpty) continue;
    groups.putIfAbsent(gid, () => <PupauMessage>[]).add(message);
  }
  return groups;
}

/// The authoritative `grounding` block only lives on the final row of a
/// `queryGroupId` (§1.1/§5 of the citations spec). Copies that one member's
/// `.grounding` onto every other member sharing the same group id, in place,
/// so `[n]` markers on earlier rows resolve against it too — both live
/// (after the debounced refetch) and on history load (REST pagination + SSE
/// reconnect `history` event). Single-row turns (no shared group, or the
/// group's only grounded member) are a no-op.
void backfillGroupGrounding(List<PupauMessage> messages) {
  final Map<String, List<PupauMessage>> groups = groupMessagesByGroupId(messages);
  for (final List<PupauMessage> members in groups.values) {
    final PupauMessage? withGrounding = members.firstWhereOrNull(
      (PupauMessage m) => m.grounding != null,
    );
    if (withGrounding == null) continue;
    for (final PupauMessage m in members) {
      m.grounding = withGrounding.grounding;
    }
  }
}

/// Newest among [members] = smallest storage index (closest to front of
/// [messagesInStorageOrder]).
PupauMessage? representativeForGroupMembers(
  List<PupauMessage> members,
  List<PupauMessage> messagesInStorageOrder,
) {
  if (members.isEmpty) return null;
  PupauMessage? bestMessage;
  int bestIdx = 1 << 30;
  for (final PupauMessage m in members) {
    final int idx = messagesInStorageOrder.indexWhere(
      (PupauMessage x) => x.id == m.id,
    );
    if (idx < 0) continue;
    if (idx < bestIdx) {
      bestIdx = idx;
      bestMessage = m;
    }
  }
  return bestMessage ?? members.last;
}

/// Identifies one *rendered row* within a group. [PupauMessage.id] alone
/// isn't enough: the user and assistant "views" of the same turn share the
/// same [PupauMessage.id] by design (see [MessageService.getUserLoadedMessage]
/// / [MessageService.getAssistantLoadedMessage]), so a plain id-keyed dedup
/// set would treat the assistant row as an already-seen duplicate of the
/// user row and silently drop it.
String _groupRowKey(PupauMessage m) =>
    m.id.isEmpty ? '' : '${m.id}_${m.isMessageFromAssistant}';

PupauMessage? firstUserMessageOldestToNewest(
  List<PupauMessage> membersOldestToNewest,
) {
  for (final PupauMessage m in membersOldestToNewest) {
    if (!m.isMessageFromAssistant) return m;
  }
  return null;
}

bool _isMeaningfulNonUserMessage(PupauMessage message) {
  if (!message.isMessageFromAssistant ||
      (message.sourceType == SourceType.event &&
          message.skillEventDetail == null)) {
    return false;
  }
  final String answer = TagService.stripThinkingForMarkdown(
    message.answer,
  ).trim();
  return answer.isNotEmpty ||
      message.toolUseMessage != null ||
      message.uiToolMessage != null ||
      message.images.isNotEmpty ||
      message.news.isNotEmpty ||
      message.organicInfo.isNotEmpty ||
      message.graphInfo != null ||
      message.urls.isNotEmpty ||
      message.relatedSearches.isNotEmpty ||
      message.transcription != null ||
      message.attachmentTrimming != null ||
      message.emergencyTrimming != null ||
      message.skillEventDetail != null;
}

PupauMessage? lastMessageInGroup(
  List<PupauMessage> membersOldestToNewest,
  List<PupauMessage> messagesInStorageOrder,
) {
  // Collapse target: latest meaningful non-user message (ignore event scaffolding
  // and empty/no-render-content frames). Tool/UI bubbles count as meaningful.
  final List<PupauMessage> assistantMessages = membersOldestToNewest
      .where(_isMeaningfulNonUserMessage)
      .toList();
  if (assistantMessages.isEmpty) return null;
  return representativeForGroupMembers(
    assistantMessages,
    messagesInStorageOrder,
  );
}

/// Messages hidden when the group row is collapsed (oldest → newest).
///
/// Defined as: all members except the collapsed-visible subset (user + latest
/// meaningful non-user message). This is robust for streaming where meaningful
/// intermediates may appear before/after the latest assistant bubble.
List<PupauMessage> intermediateMessages(
  List<PupauMessage> membersOldestToNewest,
  List<PupauMessage> messagesInStorageOrder,
) {
  final List<PupauMessage> collapsed = collapsedFlatMessagesForGroupRow(
    membersOldestToNewest,
    messagesInStorageOrder,
  );
  final Set<String> keepKeys = collapsed
      .map(_groupRowKey)
      .where((String key) => key.isNotEmpty)
      .toSet();
  final List<PupauMessage> out = <PupauMessage>[];
  for (final PupauMessage m in membersOldestToNewest) {
    if (keepKeys.contains(_groupRowKey(m))) continue;
    out.add(m);
  }
  out.removeWhere(
    (PupauMessage m) =>
        m.sourceType == SourceType.llm &&
        TagService.stripThinkingForMarkdown(m.answer).trim().isEmpty,
  );
  return out;
}

/// Collapsed group row: user (if any), all skill-event bubbles (always
/// visible), then latest assistant (if any and not already added).
List<PupauMessage> collapsedFlatMessagesForGroupRow(
  List<PupauMessage> membersOldestToNewest,
  List<PupauMessage> messagesInStorageOrder,
) {
  final PupauMessage? userMessage = firstUserMessageOldestToNewest(
    membersOldestToNewest,
  );
  final PupauMessage? lastAssistantMessage = lastMessageInGroup(
    membersOldestToNewest,
    messagesInStorageOrder,
  );
  final Set<String> addedKeys = <String>{};
  final List<PupauMessage> outMessages = <PupauMessage>[];

  void addIfNew(PupauMessage m) {
    final String key = _groupRowKey(m);
    if (key.isNotEmpty && addedKeys.contains(key)) return;
    outMessages.add(m);
    if (key.isNotEmpty) addedKeys.add(key);
  }

  if (userMessage != null) addIfNew(userMessage);

  // Skill load/unload events are always visible — never collapsed.
  for (final PupauMessage m in membersOldestToNewest) {
    if (m.skillEventDetail != null) addIfNew(m);
  }

  if (lastAssistantMessage != null) addIfNew(lastAssistantMessage);

  if (outMessages.isEmpty && membersOldestToNewest.isNotEmpty) {
    outMessages.add(membersOldestToNewest.last);
  }
  return outMessages;
}

bool groupRowNeedsExpandToggle(
  List<PupauMessage> membersOldestToNewest,
  List<PupauMessage> messagesInStorageOrder,
) {
  if (membersOldestToNewest.length <= 1) {
    return false;
  }
  return intermediateMessages(
    membersOldestToNewest,
    messagesInStorageOrder,
  ).isNotEmpty;
}

/// True when [message] shares a non-empty [PupauMessage.groupId] with at
/// least one other message and the list row can hide messages until expanded.
bool messageGroupHasExpandCollapse(
  PupauMessage message,
  List<PupauMessage> messages,
) {
  final String gid = message.groupId.trim();
  if (gid.isEmpty) return false;
  final List<PupauMessage> sameGroup = messages
      .where((PupauMessage m) => m.groupId.trim() == gid)
      .toList();
  sameGroup.removeWhere(
    (PupauMessage m) =>
        m.sourceType == SourceType.llm &&
        TagService.stripThinkingForMarkdown(m.answer).trim().isEmpty,
  );
  if (sameGroup.length <= 1) return false;
  final List<PupauMessage> oldestToNewest = messagesOldestToNewest(sameGroup);
  return groupRowNeedsExpandToggle(oldestToNewest, messages);
}

PupauMessage bottomMessageForGroupRow(
  List<PupauMessage> membersOldestToNewest,
  List<PupauMessage> messagesInStorageOrder,
  bool expanded,
) {
  if (expanded) {
    return membersOldestToNewest.last;
  }
  final List<PupauMessage> collapsed = collapsedFlatMessagesForGroupRow(
    membersOldestToNewest,
    messagesInStorageOrder,
  );
  return collapsed.last;
}

/// One sliver row: either a single message (no group id) or one query group.
class GroupedVisibleRow {
  const GroupedVisibleRow._singleton(this.singletonMessage)
    : groupId = null,
      groupMembersOldestToNewest = const <PupauMessage>[];

  const GroupedVisibleRow._group(this.groupId, this.groupMembersOldestToNewest)
    : singletonMessage = null;

  factory GroupedVisibleRow.singleton(PupauMessage m) =>
      GroupedVisibleRow._singleton(m);

  factory GroupedVisibleRow.group(
    String groupId,
    List<PupauMessage> membersOldestToNewest,
  ) => GroupedVisibleRow._group(groupId, membersOldestToNewest);

  final PupauMessage? singletonMessage;
  final String? groupId;
  final List<PupauMessage> groupMembersOldestToNewest;

  bool get isSingleton => singletonMessage != null;
}

List<GroupedVisibleRow> buildVisibleMessageRows(List<PupauMessage> messages) {
  final List<PupauMessage> ordered = messagesOldestToNewest(messages);
  final Map<String, List<PupauMessage>> groups = groupMessagesByGroupId(
    ordered,
  );
  final List<GroupedVisibleRow> rows = <GroupedVisibleRow>[];
  final Set<String> emittedGroupIds = <String>{};
  for (final PupauMessage m in ordered) {
    final String gid = m.groupId.trim();
    if (gid.isEmpty) {
      rows.add(GroupedVisibleRow.singleton(m));
      continue;
    }
    if (emittedGroupIds.contains(gid)) {
      continue;
    }
    emittedGroupIds.add(gid);
    final List<PupauMessage>? members = groups[gid];
    if (members == null || members.isEmpty) {
      continue;
    }
    if (members.length == 1) {
      rows.add(GroupedVisibleRow.singleton(members.single));
    } else {
      rows.add(GroupedVisibleRow.group(gid, List<PupauMessage>.from(members)));
    }
  }
  return rows;
}
