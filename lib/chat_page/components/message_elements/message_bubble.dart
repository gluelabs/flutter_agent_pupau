import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_context_menu.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_load_error_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_menu_tip.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_stream_builder.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/my_context_menu_region.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';

class MessageBubble extends GetView<ChatController> {
  const MessageBubble({
    super.key,
    required this.assistant,
    required this.message,
    this.isReadOnly = false,
  });

  final Assistant? assistant;
  final PupauMessage message;
  final bool isReadOnly;

  Key get messageKey => ValueKey('${message.id}_${message.isCancelled}');

  @override
  Widget build(BuildContext context) {
    bool isAssistant = message.isMessageFromAssistant;
    Reaction reaction = message.reaction ?? Reaction.none;
    bool isLoadingMessage = message.status == MessageStatus.loading;
    bool isLoadingAssistantMessage = isLoadingMessage && isAssistant;
    bool isImageSearch =
        message.images.isNotEmpty && isAssistant && message.answer.isEmpty;
    return Obx(() {
      bool isLastMessage = message == controller.messages.firstOrNull;
      bool isAnonymous = controller.isAnonymous;
      bool showMenuTip = isAssistant &&
          isLastMessage &&
          !controller.stopIsActive() &&
          !PupauSharedPreferences.getTutorialMessageMenuDone();
      return AbsorbPointer(
        absorbing: controller.stopIsActive() ||
            message.isInitialMessage ||
            isReadOnly ||
            (isAssistant && message.status == MessageStatus.loading),
        child: MyContextMenuRegion(
          contextMenu: getContextMenu(isAssistant, reaction, controller.hideInputBox),
          onItemSelected: isReadOnly
              ? null
              : (selectedOption) {
                  if (selectedOption != null) {
                    controller.manageMessageContextMenu(
                        selectedOption, message);
                  }
                },
          child: isImageSearch
              ? const SizedBox()
              : Bubble(
                  key:
                      messageKey, // Use the reactive key to force rebuild when updating isCancelled
                  radius: const Radius.circular(20),
                  elevation: 0,
                  style: StyleService.getBubbleStyle(
                      isAnonymous, isAssistant, message.isCancelled),
                  nip: isAssistant ? BubbleNip.no : BubbleNip.rightTop,
                  padding: isAssistant ? BubbleEdges.all(0) : null,
                  child: Column(
                    crossAxisAlignment: isAssistant
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      if (message.status == MessageStatus.error)
                        MessageLoadErrorInfo(),
                      isLoadingAssistantMessage
                          ? MessageStreamBuilder(
                              message: message, assistant: assistant)
                          : MessageContent(
                              messageId: message.id,
                              message: isAssistant ? message.answer : message.query,
                              createdAt: message.createdAt,
                              isAssistant: isAssistant,
                              isAnonymous: isAnonymous,
                              assistant: assistant,
                              contextInfo: message.contextInfo),
                      if (showMenuTip) MessageMenuTip()
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
