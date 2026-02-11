import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_notifier.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

class MessageStreamBuilder extends GetView<ChatController> {
  const MessageStreamBuilder({
    super.key,
    required this.message,
    required this.assistant,
  });

  final PupauMessage message;
  final Assistant? assistant;

  @override
  Widget build(BuildContext context) {
    NotifierMessage? notifierMessage = controller.messageNotifier.messages
        .firstWhereOrNull(
          (NotifierMessage notifierMessage) =>
              notifierMessage.idMessage == message.id,
        );
    bool isAnonymous = controller.isAnonymous;
    return ListenableBuilder(
      listenable: controller.messageNotifier,
      builder: (BuildContext context, Widget? child) {
        return notifierMessage == null || notifierMessage.message.isEmpty
            ? const SizedBox()
            : MessageContent(
                messageId: message.id,
                message: notifierMessage.message,
                status: message.status,
                createdAt: message.createdAt,
                isAssistant: true,
                isAnonymous: isAnonymous,
                assistant: assistant,
                contextInfo: message.contextInfo,
                isAudioInput: message.isAudioInput,
              );
      },
    );
  }
}
