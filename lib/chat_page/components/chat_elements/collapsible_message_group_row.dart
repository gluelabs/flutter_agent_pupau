import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/height_reporting_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/message_group_toggle_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/message_group_intermediate_messages.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/message_with_optional_date_header.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/message_grouping_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

/// Renders a grouped row with an expand/collapse control.
///
/// Layout (kept identical to previous implementation):
/// - user message
/// - toggle under user message (Expand only when collapsed; Collapse when expanded)
/// - intermediate messages (animated size)
/// - toggle above last assistant (Collapse only)
/// - last assistant message
class CollapsibleMessageGroupRow extends StatelessWidget {
  const CollapsibleMessageGroupRow({
    super.key,
    required this.chatController,
    required this.visibleIndex,
    required this.visibleRows,
    required this.messages,
    required this.row,
    required this.showDateHeaderForDay,
    required this.conversationLatestMessageId,
    required this.bottomMessageForVisibleRow,
    required this.shouldReportAssistantClusterHeight,
  });

  final PupauChatController chatController;
  final int visibleIndex;
  final List<GroupedVisibleRow> visibleRows;
  final List<PupauMessage> messages;
  final GroupedVisibleRow row;
  final bool Function(DateTime date) showDateHeaderForDay;
  final String? conversationLatestMessageId;
  final bool shouldReportAssistantClusterHeight;

  final PupauMessage? Function({
    required int visibleIndex,
    required List<GroupedVisibleRow> visibleRows,
    required List<PupauMessage> messages,
    required PupauChatController controller,
  }) bottomMessageForVisibleRow;

  @override
  Widget build(BuildContext context) {
    final List<PupauMessage> members = row.groupMembersOldestToNewest;
    final String gid = row.groupId!.trim();
    final PupauMessage? user = firstUserMessageOldestToNewest(members);
    final PupauMessage? lastAssistant = lastMessageInGroup(members, messages);
    final List<PupauMessage> intermediates =
        intermediateMessages(members, messages);
    final bool expanded = chatController.isMessageGroupExpanded(gid);
    // Skill events are pinned above intermediates (never collapsed).
    // Exclude any that are already the lastAssistant to avoid duplication.
    final List<PupauMessage> pinnedSkillEvents = members
        .where(
          (PupauMessage m) =>
              m.skillEventDetail != null &&
              m.id != (lastAssistant?.id ?? ''),
        )
        .toList();

    final PupauMessage? olderBeforeUser = visibleIndex == 0
        ? null
        : bottomMessageForVisibleRow(
            visibleIndex: visibleIndex - 1,
            visibleRows: visibleRows,
            messages: messages,
            controller: chatController,
          );

    final List<Widget> children = <Widget>[];

    if (user != null) {
      children.add(
        MessageWithOptionalDateHeader(
          message: user,
          olderAbove: olderBeforeUser,
          isGlobalTop: visibleIndex == 0,
          showDateHeaderForDay: showDateHeaderForDay,
          conversationLatestMessageId: conversationLatestMessageId,
        ),
      );
      // Skill load/unload cards appear between the user message and the toggle.
      for (int k = 0; k < pinnedSkillEvents.length; k++) {
        final PupauMessage m = pinnedSkillEvents[k];
        final PupauMessage prev = k == 0 ? user : pinnedSkillEvents[k - 1];
        children.add(
          MessageWithOptionalDateHeader(
            message: m,
            olderAbove: prev,
            isGlobalTop: false,
            showDateHeaderForDay: showDateHeaderForDay,
            conversationLatestMessageId: conversationLatestMessageId,
          ),
        );
      }
      children.add(
        MessageGroupToggleButton(
          groupId: gid,
          isExpanded: expanded,
          isUnderUserMessage: true,
          collapsedCount: intermediates.length,
          onPressed: () => chatController.toggleMessageGroupExpanded(gid),
        ),
      );
    }

    Widget assistantCluster = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        MessageGroupIntermediateMessages(
          groupId: gid,
          isExpanded: expanded,
          hasIntermediates: intermediates.isNotEmpty,
          child: Column(
            key: ValueKey<String>('group_intermediate_visible_$gid'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(intermediates.length, (int k) {
              final PupauMessage m = intermediates[k];
              final PupauMessage? prev = k == 0
                  ? (pinnedSkillEvents.isNotEmpty
                      ? pinnedSkillEvents.last
                      : (user ?? olderBeforeUser))
                  : intermediates[k - 1];
              return MessageWithOptionalDateHeader(
                message: m,
                olderAbove: prev,
                isGlobalTop: visibleIndex == 0 &&
                    user == null &&
                    pinnedSkillEvents.isEmpty &&
                    k == 0,
                showDateHeaderForDay: showDateHeaderForDay,
                conversationLatestMessageId: conversationLatestMessageId,
              );
            }),
          ),
        ),
        MessageGroupToggleButton(
          groupId: gid,
          isExpanded: expanded,
          isUnderUserMessage: false,
          onPressed: () => chatController.toggleMessageGroupExpanded(gid),
        ),
        if (lastAssistant != null)
          MessageWithOptionalDateHeader(
            message: lastAssistant,
            olderAbove: expanded && intermediates.isNotEmpty
                ? intermediates.last
                : (pinnedSkillEvents.isNotEmpty
                    ? pinnedSkillEvents.last
                    : user),
            isGlobalTop: visibleIndex == 0 &&
                user == null &&
                pinnedSkillEvents.isEmpty &&
                (!expanded || intermediates.isEmpty),
            showDateHeaderForDay: showDateHeaderForDay,
            conversationLatestMessageId: conversationLatestMessageId,
          ),
      ],
    );

    if (shouldReportAssistantClusterHeight) {
      assistantCluster = HeightReportingContainer(
        onHeight: chatController.setLatestQueryAssistantClusterHeight,
        child: assistantCluster,
      );
    }

    children.add(assistantCluster);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}
