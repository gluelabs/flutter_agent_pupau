import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_loading_message.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/conversation_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/initial_message.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/chat_date_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_elements.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';

class MessagesList extends GetView<ChatController> {
  const MessagesList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    AttachmentsController attachmentsController =
        Get.find<AttachmentsController>();
    return CustomScrollView(
        controller: controller.chatScrollController,
        physics: const ClampingScrollPhysics(),
        cacheExtent: 500, // Limit off-screen rendering to improve performance
        slivers: [
          const ConversationTitle(),
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => controller.keyboardFocusNode.unfocus(),
              child: Transform.translate(
                offset: const Offset(0, -42),
                child: InitialMessage(),
              ),
            ),
          ),
          Obx(() {
            List<PupauMessage> messages = controller.messages;
            bool showDate(DateTime date) =>
                controller.conversation.value != null &&
                date.day !=
                    controller.conversation.value?.createdAt.day;
            
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Since messages are reversed, we need to reverse the index
                  int reversedIndex = messages.length - 1 - index;
                  PupauMessage message = messages[reversedIndex];
                  
                  if (message.attachments.isEmpty) {
                    message.attachments = attachmentsController
                        .getMessageAttachments(message);
                  }
                  
                  int lastIndex = messages.length - 1;
                  bool isLastIndex = reversedIndex == lastIndex;
                  bool isDifferentDay = false;
                  if (!isLastIndex && reversedIndex != lastIndex - 1) {
                    isDifferentDay = ConversationService.isDifferentDay(
                        message.createdAt,
                        messages[reversedIndex + 1].createdAt);
                  }
                  
                  if (isLastIndex || isDifferentDay) {
                    DateTime now = DateTime.now();
                    DateTime date = messages.length == 1
                        ? now
                        : isLastIndex
                            ? messages[reversedIndex - 1].createdAt
                            : message.createdAt;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (showDate(date))
                          ChatDateContainer(date: date),
                        MessageElements(message: message)
                      ],
                    );
                  }
                  return MessageElements(message: message);
                },
                childCount: messages.length,
                addAutomaticKeepAlives: false, // Don't keep off-screen items alive
                addRepaintBoundaries: true, // Add repaint boundaries for better performance
              ),
            );
          }),
          Obx(() {
            if (controller.isLoadingMessageActive()) {
              return const SliverToBoxAdapter(
                child: ChatLoadingMessage(),
              );
            }
            return const SliverToBoxAdapter(child: SizedBox.shrink());
          }),
          // Add bottom padding to compensate for Transform.translate negative offset
          // This ensures the scroll extent is calculated correctly and prevents bounce
          // The padding accounts for the -42px offset plus extra space for loading messages
          const SliverPadding(
            padding: EdgeInsets.only(bottom: 42),
          ),
        ]);
  }
}
