import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/chat_date_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_elements.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:get/get.dart';

/// Wraps a message and conditionally prepends a date header.
class MessageWithOptionalDateHeader extends StatelessWidget {
  const MessageWithOptionalDateHeader({
    super.key,
    required this.message,
    required this.olderAbove,
    required this.isGlobalTop,
    required this.showDateHeaderForDay,
    required this.conversationLatestMessageId,
  });

  final PupauMessage message;
  final PupauMessage? olderAbove;
  final bool isGlobalTop;
  final bool Function(DateTime date) showDateHeaderForDay;
  final String? conversationLatestMessageId;

  Widget _messageElements(PupauChatController controller) {
    final bool? latestOverride = conversationLatestMessageId == null
        ? null
        : message.id == conversationLatestMessageId;
    final Widget inner = MessageElements(
      message: message,
      isConversationLatestMessageOverride: latestOverride,
    );
    if (controller.pendingScrollAlignUserMessageId.value == message.id) {
      return KeyedSubtree(
        key: controller.scrollAlignSentUserBubbleKey,
        child: inner,
      );
    }
    return inner;
  }

  @override
  Widget build(BuildContext context) {
    final PupauChatController controller = Get.find<PupauChatController>();
    final Widget messageWidget = _messageElements(controller);

    if (isGlobalTop) {
      final List<Widget> parts = <Widget>[
        ChatDateContainer(date: message.createdAt),
        messageWidget,
      ];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: parts,
      );
    }

    final bool hasDayBreak =
        olderAbove != null &&
        ConversationService.isDifferentDay(
          message.createdAt,
          olderAbove!.createdAt,
        );
    if (!hasDayBreak) {
      return messageWidget;
    }

    final List<Widget> parts = <Widget>[];
    if (showDateHeaderForDay(message.createdAt)) {
      parts.add(ChatDateContainer(date: message.createdAt));
    }
    parts.add(messageWidget);
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: parts);
  }
}
