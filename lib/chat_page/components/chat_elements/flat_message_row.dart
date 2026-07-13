import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/height_reporting_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/message_with_optional_date_header.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/message_grouping_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

/// Renders a non-grouped (flat) row of one or more messages.
class FlatMessageRow extends StatelessWidget {
  const FlatMessageRow({
    super.key,
    required this.chatController,
    required this.flat,
    required this.visibleIndex,
    required this.visibleRows,
    required this.messages,
    required this.showDateHeaderForDay,
    required this.conversationLatestMessageId,
    required this.bottomMessageForVisibleRow,
    required this.shouldReportAssistantClusterHeight,
  });

  final PupauChatController chatController;
  final List<PupauMessage> flat;
  final int visibleIndex;
  final List<GroupedVisibleRow> visibleRows;
  final List<PupauMessage> messages;
  final bool Function(DateTime date) showDateHeaderForDay;
  final String? conversationLatestMessageId;
  final bool shouldReportAssistantClusterHeight;

  final PupauMessage? Function({
    required int visibleIndex,
    required List<GroupedVisibleRow> visibleRows,
    required List<PupauMessage> messages,
    required PupauChatController controller,
  }) bottomMessageForVisibleRow;

  PupauMessage? _olderAboveForIndex(int j) {
    if (j > 0) {
      return flat[j - 1];
    }
    if (visibleIndex == 0) {
      return null;
    }
    return bottomMessageForVisibleRow(
      visibleIndex: visibleIndex - 1,
      visibleRows: visibleRows,
      messages: messages,
      controller: chatController,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!shouldReportAssistantClusterHeight) {
      return _buildPlainColumn();
    }
    return _buildColumnWithAssistantReporting();
  }

  Widget _buildPlainColumn() {
    final List<Widget> children = <Widget>[];
    for (int j = 0; j < flat.length; j++) {
      final PupauMessage m = flat[j];
      children.add(
        MessageWithOptionalDateHeader(
          message: m,
          olderAbove: _olderAboveForIndex(j),
          isGlobalTop: visibleIndex == 0 && j == 0,
          showDateHeaderForDay: showDateHeaderForDay,
          conversationLatestMessageId: conversationLatestMessageId,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  Widget _buildColumnWithAssistantReporting() {
    final List<Widget> children = <Widget>[];
    int j = 0;
    while (j < flat.length) {
      final PupauMessage m = flat[j];
      if (!m.isMessageFromAssistant) {
        children.add(
          MessageWithOptionalDateHeader(
            message: m,
            olderAbove: _olderAboveForIndex(j),
            isGlobalTop: visibleIndex == 0 && j == 0,
            showDateHeaderForDay: showDateHeaderForDay,
            conversationLatestMessageId: conversationLatestMessageId,
          ),
        );
        j++;
      } else {
        final int blockStart = j;
        final List<Widget> assistantWidgets = <Widget>[];
        int withinBlock = 0;
        while (j < flat.length && flat[j].isMessageFromAssistant) {
          assistantWidgets.add(
            MessageWithOptionalDateHeader(
              message: flat[j],
              olderAbove: _olderAboveForIndex(j),
              isGlobalTop:
                  visibleIndex == 0 && blockStart == 0 && withinBlock == 0,
              showDateHeaderForDay: showDateHeaderForDay,
              conversationLatestMessageId: conversationLatestMessageId,
            ),
          );
          withinBlock++;
          j++;
        }
        final Widget cluster = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: assistantWidgets,
        );
        children.add(
          HeightReportingContainer(
            onHeight: chatController.setLatestQueryAssistantClusterHeight,
            child: cluster,
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }
}
