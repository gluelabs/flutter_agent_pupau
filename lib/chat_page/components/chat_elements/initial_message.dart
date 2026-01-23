import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/chat_date_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_elements.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

class InitialMessage extends GetView<ChatController> {
  const InitialMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      String messageText = TagService.addUserNameTag(
        controller.assistant.value?.welcomeMessage ?? "",
      );
      bool isEmpty = messageText.trim() == "";
      DateTime firstMessageDate =
          controller.messages.lastOrNull?.createdAt ?? DateTime.now();
      return Column(
        children: [
          ChatDateContainer(date: firstMessageDate),
          MessageElements(
            message: PupauMessage(
              id: "",
              assistantId: controller.assistant.value?.id ?? "",
              createdAt: firstMessageDate,
              answer: messageText,
              status: isEmpty ? MessageStatus.loading : MessageStatus.received,
              isInitialMessage: true,
              assistantType:
                  controller.assistant.value?.type ?? AssistantType.assistant,
            ),
          ),
        ],
      );
    });
  }
}
