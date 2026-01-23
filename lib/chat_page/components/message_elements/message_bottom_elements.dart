import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/kb_references_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/knowledge_base_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_time_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/reaction_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/text_to_speach_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';

class MessageBottomElements extends GetView<ChatController> {
  const MessageBottomElements({super.key, required this.message});

  final PupauMessage message;

  @override
  Widget build(BuildContext context) {
    Reaction reaction = message.reaction ?? Reaction.none;
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      bool isAnonymous = controller.isAnonymous;
      bool isActionBarAlwaysVisible =
          controller.isActionBarAlwaysVisible.value;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          KnowledgeBaseInfo(
            message: message,
            onTap: () {
              FocusScope.of(context).unfocus();
              showKBReferencesModal(message.kbReferences);
            },
          ),
          MessageTimeInfo(
              localDate: message.createdAt.toLocal(), isAssistant: true),
          if (reaction != Reaction.none && !isActionBarAlwaysVisible)
            ReactionIcon(
              isAnonymous: isAnonymous,
              reaction: reaction,
              onTap: () {
                controller.reactMessage(message, Reaction.none);
                message.reaction = Reaction.none;
                controller.messages.refresh();
                controller.update();
              },
            ),
          if (message.isNarrating && !isActionBarAlwaysVisible)
            TextToSpeachIcon(
              message: message,
              isAnonymous: isAnonymous,
            ),
          SizedBox(height: isTablet ? 32 : 28)
        ],
      );
    });
  }
}
