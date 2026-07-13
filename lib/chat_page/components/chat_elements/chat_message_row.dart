import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/collapsible_message_group_row.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/flat_message_row.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/utils/message_grouping_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

/// Renders a single "visible row" in the chat message list.
///
/// A row is either:
/// - a grouped/collapsible message group row, or
/// - a flat row containing one or more messages.
class ChatMessageRow extends StatelessWidget {
  const ChatMessageRow({
    super.key,
    required this.chatController,
    required this.visibleIndex,
    required this.visibleRows,
    required this.messages,
    required this.showDateHeaderForDay,
    required this.conversationLatestMessageId,
    required this.flatMessagesForVisibleRow,
    required this.bottomMessageForVisibleRow,
  });

  final PupauChatController chatController;
  final int visibleIndex;
  final List<GroupedVisibleRow> visibleRows;
  final List<PupauMessage> messages;
  final bool Function(DateTime date) showDateHeaderForDay;
  final String? conversationLatestMessageId;

  final List<PupauMessage> Function({
    required GroupedVisibleRow row,
    required List<PupauMessage> messages,
    required PupauChatController controller,
  }) flatMessagesForVisibleRow;

  final PupauMessage? Function({
    required int visibleIndex,
    required List<GroupedVisibleRow> visibleRows,
    required List<PupauMessage> messages,
    required PupauChatController controller,
  }) bottomMessageForVisibleRow;

  @override
  Widget build(BuildContext context) {
    final GroupedVisibleRow row = visibleRows[visibleIndex];
    final bool isLastVisibleRow = visibleIndex == visibleRows.length - 1;
    return Obx(() {
      // Always read .value first — short-circuit `&&` would skip observation on
      // non-last rows and trigger GetX "no observable" improper use.
      chatController.messageGroupExpandEpoch.value;
      final bool paddingActive =
          chatController.chatExtraBottomPaddingActive.value;
      final bool shouldReportAssistantClusterHeight =
          isLastVisibleRow && paddingActive;
      if (!row.isSingleton) {
        final List<PupauMessage> members = row.groupMembersOldestToNewest;
        final bool needsAnimatedToggle =
            groupRowNeedsExpandToggle(members, messages);
        if (needsAnimatedToggle) {
          return CollapsibleMessageGroupRow(
            chatController: chatController,
            visibleIndex: visibleIndex,
            visibleRows: visibleRows,
            messages: messages,
            row: row,
            showDateHeaderForDay: showDateHeaderForDay,
            conversationLatestMessageId: conversationLatestMessageId,
            bottomMessageForVisibleRow: bottomMessageForVisibleRow,
            shouldReportAssistantClusterHeight: shouldReportAssistantClusterHeight,
          );
        }
      }

      final List<PupauMessage> flat = flatMessagesForVisibleRow(
        row: row,
        messages: messages,
        controller: chatController,
      );

      return FlatMessageRow(
        chatController: chatController,
        flat: flat,
        visibleIndex: visibleIndex,
        visibleRows: visibleRows,
        messages: messages,
        showDateHeaderForDay: showDateHeaderForDay,
        conversationLatestMessageId: conversationLatestMessageId,
        bottomMessageForVisibleRow: bottomMessageForVisibleRow,
        shouldReportAssistantClusterHeight: shouldReportAssistantClusterHeight,
      );
    });
  }
}
