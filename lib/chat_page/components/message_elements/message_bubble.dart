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

class MessageBubble extends StatefulWidget {
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
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  VoidCallback? _userBubbleToggle;

  void _registerUserBubbleToggle(VoidCallback? fn) {
    if (!mounted) return;

    final bool hadHandler = _userBubbleToggle != null;
    final bool hasHandler = fn != null;
    _userBubbleToggle = fn;
    if (hadHandler != hasHandler) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final PupauChatController controller = Get.find<PupauChatController>();
    final bool isAssistant = widget.message.isMessageFromAssistant;
    final Reaction reaction = widget.message.reaction ?? Reaction.none;
    final bool isLoadingMessage =
        widget.message.status == MessageStatus.loading;
    final bool isLoadingAssistantMessage = isLoadingMessage && isAssistant;
    final bool isImageSearch =
        widget.message.images.isNotEmpty &&
        isAssistant &&
        widget.message.answer.isEmpty;
    return Obx(() {
      final bool isLastMessage =
          widget.message == controller.messages.firstOrNull;
      final bool isAnonymous = controller.isAnonymous;
      final bool showMenuTip =
          isAssistant &&
          isLastMessage &&
          !controller.stopIsActive() &&
          !PupauSharedPreferences.getTutorialMessageMenuDone();
      final String messageText = isAssistant
          ? widget.message.answer
          : widget.message.query;

      Widget bubbleChild = Bubble(
        key: widget.messageKey,
        radius: const Radius.circular(20),
        elevation: 0,
        style: StyleService.getBubbleStyle(
          isAnonymous,
          isAssistant,
          widget.message.isCancelled,
        ),
        nip: isAssistant ? BubbleNip.no : BubbleNip.rightTop,
        padding: isAssistant ? BubbleEdges.all(0) : null,
        child: Column(
          crossAxisAlignment: isAssistant
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: <Widget>[
            if (widget.message.status == MessageStatus.error)
              MessageLoadErrorInfo(),
            isLoadingAssistantMessage
                ? MessageStreamBuilder(
                    message: widget.message,
                    assistant: widget.assistant,
                  )
                : MessageContent(
                    messageId: widget.message.id,
                    message: messageText,
                    status: widget.message.status,
                    createdAt: widget.message.createdAt,
                    isAssistant: isAssistant,
                    isAnonymous: isAnonymous,
                    assistant: widget.assistant,
                    contextInfo: widget.message.contextInfo,
                    grounding: widget.message.grounding,
                    isAudioInput: widget.message.isAudioInput,
                    onRegisterUserBubbleToggle: isAssistant
                        ? null
                        : _registerUserBubbleToggle,
                    userBubbleExpandTap: isAssistant ? null : _userBubbleToggle,
                  ),
            if (showMenuTip) MessageMenuTip(),
          ],
        ),
      );

      return AbsorbPointer(
        absorbing:
            controller.stopIsActive() ||
            widget.isReadOnly ||
            (isAssistant && widget.message.status == MessageStatus.loading),
        child: MyContextMenuRegion(
          contextMenu: getContextMenu(
            isAssistant,
            reaction,
            controller.hideInputBox.value,
            message: widget.message,
          ),
          onItemSelected: widget.isReadOnly
              ? null
              : (dynamic selectedOption) {
                  if (selectedOption != null) {
                    controller.manageMessageContextMenu(
                      selectedOption,
                      widget.message,
                    );
                  }
                },
          child: isImageSearch ? const SizedBox() : bubbleChild,
        ),
      );
    });
  }
}
