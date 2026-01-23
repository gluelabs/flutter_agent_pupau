import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/context_info_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_body.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_sender_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_time_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/prompt_options_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/reflection_tag_container.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/prompt_option_model.dart';
import 'package:flutter_agent_pupau/models/prompt_reflection_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

class MessageContent extends StatelessWidget {
  const MessageContent(
      {super.key,
      required this.messageId,
      required this.message,
      required this.createdAt,
      required this.isAssistant,
      required this.isAnonymous,
      this.assistant,
      this.contextInfo});

  final String messageId;
  final String message;
  final DateTime? createdAt;
  final bool isAssistant;
  final bool isAnonymous;
  final Assistant? assistant;
  final ContextInfo? contextInfo;

  @override
  Widget build(BuildContext context) {
    List<PromptOption> options = isAssistant
        ? TagService.extractOptions(message, messageId)
        : [];
    bool hasOptionsTag =
        TagService.hasOptionsClosingTag(message) && isAssistant;
    bool hasReflectionTag =
        TagService.hasReflectionClosingTag(message) && isAssistant;
    PromptReflection? reflection = hasReflectionTag
        ? TagService.extractReflection(message, messageId)
        : null;
    bool isLoading = message.trim() == "" ||
        TagService.hasLoadingThinkingTag(message);
    return isLoading
        ? const SizedBox()
        : Column(
            crossAxisAlignment: isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isAssistant) MessageSenderInfo(assistant: assistant),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MessageBody(
                      message: message,
                      isFromAssistant: isAssistant,
                      isAnonymous: isAnonymous)
                ],
              ),
              if (hasOptionsTag && options.isNotEmpty)
                PromptOptionsList(options: options),
              if (hasReflectionTag &&
                  reflection != null &&
                  reflection.text.isNotEmpty)
                ReflectionTagContainer(reflection: reflection),
              if (contextInfo != null)
                ContextInfoContainer(contextInfo: contextInfo!),
              if (!isAssistant)
                MessageTimeInfo(
                    localDate: createdAt?.toLocal(),
                    isAssistant: false),
            ],
          );
  }
}
