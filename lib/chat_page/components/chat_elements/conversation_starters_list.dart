import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/conversation_starter_chip.dart';
import 'package:get/get.dart';
import '../../controllers/chat_controller.dart';

class ConversationStartersList extends GetView<ChatController> {
  const ConversationStartersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<String> conversationStarters = controller.conversationStarters;
      bool showConversationStarters = controller.showConversationStarters;
      if (!showConversationStarters) return const SizedBox();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 15, right: 15),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (String starter in conversationStarters)
                ConversationStarterChip(starter: starter),
            ],
          ),
        ),
      );
    });
  }
}
