import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_loading_message.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/conversation_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_message_row.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/message_grouping_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

class MessagesList extends GetView<PupauChatController> {
  const MessagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final PupauAttachmentsController attachmentsController =
        Get.find<PupauAttachmentsController>();
    return CustomScrollView(
      controller: controller.chatScrollController,
      physics: const ClampingScrollPhysics(),
      scrollCacheExtent: ScrollCacheExtent.pixels(700),
      slivers: <Widget>[
        const ConversationTitle(),
        Obx(() {
          final List<PupauMessage> messages = controller.messages;
          controller.messageGroupExpandEpoch.value;

          for (final PupauMessage m in messages) {
            if (m.attachments.isEmpty) {
              m.attachments = attachmentsController.getMessageAttachments(m);
            }
          }

          final List<GroupedVisibleRow> visibleRows = buildVisibleMessageRows(
            messages,
          );
          final String? conversationLatestMessageId = messages.firstOrNull?.id;
          final DateTime conversationCreatedAt =
              controller.conversation.value?.createdAt ?? DateTime.now();

          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext rowContext, int index) {
                return ChatMessageRow(
                  chatController: controller,
                  visibleIndex: index,
                  visibleRows: visibleRows,
                  messages: messages,
                  showDateHeaderForDay: (DateTime date) =>
                      ConversationService.isDifferentDay(
                        date,
                        conversationCreatedAt,
                      ),
                  conversationLatestMessageId: conversationLatestMessageId,
                  flatMessagesForVisibleRow: _flatMessagesForVisibleRow,
                  bottomMessageForVisibleRow: _bottomMessageForVisibleRow,
                );
              },
              childCount: visibleRows.length,
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          );
        }),
        Obx(() {
          return SliverToBoxAdapter(
            child: controller.isStreaming.value
                ? ChatLoadingMessage()
                : SizedBox.shrink(),
          );
        }),
        Obx(() {
          // Observe both Rx values before branching — early return would skip
          // [latestQueryAssistantClusterHeight] and break GetX observation.
          final bool paddingActive =
              controller.chatExtraBottomPaddingActive.value;
          final double assistantClusterH =
              controller.latestQueryAssistantClusterHeight.value;
          if (!paddingActive) {
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }
          return SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double viewHeight = MediaQuery.sizeOf(context).height;
                final double baseSlack = (viewHeight * 0.55).clamp(
                  140.0,
                  540.0,
                );
                final double remainingSlack =
                    (baseSlack -
                            (assistantClusterH < baseSlack
                                ? assistantClusterH
                                : baseSlack))
                        .clamp(0.0, double.infinity);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  height: remainingSlack,
                  color: Colors.transparent,
                  alignment: Alignment.topCenter,
                  child: const SizedBox(width: double.infinity),
                );
              },
            ),
          );
        }),
        const SliverPadding(padding: EdgeInsets.only(bottom: 42)),
      ],
    );
  }
}

List<PupauMessage> _flatMessagesForVisibleRow({
  required GroupedVisibleRow row,
  required List<PupauMessage> messages,
  required PupauChatController controller,
}) {
  if (row.isSingleton) {
    return <PupauMessage>[row.singletonMessage!];
  }
  final String gid = row.groupId!.trim();
  final List<PupauMessage> members = row.groupMembersOldestToNewest;
  if (members.length <= 1) {
    return members;
  }
  if (controller.isMessageGroupExpanded(gid)) {
    return members;
  }
  return collapsedFlatMessagesForGroupRow(members, messages);
}

PupauMessage _bottomMessageForVisibleRow({
  required int visibleIndex,
  required List<GroupedVisibleRow> visibleRows,
  required List<PupauMessage> messages,
  required PupauChatController controller,
}) {
  final GroupedVisibleRow row = visibleRows[visibleIndex];
  if (row.isSingleton) {
    return row.singletonMessage!;
  }
  final String gid = row.groupId!.trim();
  final List<PupauMessage> members = row.groupMembersOldestToNewest;
  return bottomMessageForGroupRow(
    members,
    messages,
    controller.isMessageGroupExpanded(gid),
  );
}
