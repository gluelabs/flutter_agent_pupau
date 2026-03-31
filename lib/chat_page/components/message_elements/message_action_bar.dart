import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/warning_action_bar_icon.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/fork_conversation_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_copy_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/reaction_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/text_to_speach_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

bool _hasTrimmingContent(AttachmentTrimmingInfo? info) {
  if (info == null || !info.applied) return false;
  return info.truncatedCount > 0 ||
      info.removedCount > 0 ||
      info.items.isNotEmpty;
}

class MessageActionBar extends GetView<PupauChatController> {
  const MessageActionBar({super.key, required this.message});

  final PupauMessage message;

  @override
  Widget build(BuildContext context) {
    Reaction reaction = message.reaction ?? Reaction.none;
    bool isAnonymous = controller.isAnonymous;
    bool showForkConversationIcon = controller.pupauConfig?.bearerToken != null;
    final bool hasTrimmingContent =
        _hasTrimmingContent(message.attachmentTrimming) ||
        _hasTrimmingContent(message.emergencyTrimming);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Opacity(
        opacity: 0.8,
        child: Row(
          spacing: 6,
          children: [
            MessageCopyIcon(message: message, isAnonymous: isAnonymous),
            Tooltip(
              message: Strings.like.tr,
              child: ReactionIcon(
                isAnonymous: isAnonymous,
                reaction: Reaction.like,
                isSelected: reaction == Reaction.like,
                onTap: () {
                  controller.reactMessage(
                    message,
                    reaction == Reaction.like ? Reaction.none : Reaction.like,
                  );
                  message.reaction = reaction == Reaction.like
                      ? Reaction.none
                      : Reaction.like;
                  controller.messages.refresh();
                  controller.update();
                },
              ),
            ),
            Tooltip(
              message: Strings.dislike.tr,
              child: ReactionIcon(
                isAnonymous: isAnonymous,
                reaction: Reaction.dislike,
                isSelected: reaction == Reaction.dislike,
                onTap: () {
                  controller.reactMessage(
                    message,
                    reaction == Reaction.dislike
                        ? Reaction.none
                        : Reaction.dislike,
                  );
                  message.reaction = reaction == Reaction.dislike
                      ? Reaction.none
                      : Reaction.dislike;
                  controller.messages.refresh();
                  controller.update();
                },
              ),
            ),
            TextToSpeachIcon(message: message, isAnonymous: isAnonymous),
            if (showForkConversationIcon)
              ForkConversationIcon(message: message, isAnonymous: isAnonymous),
            if (hasTrimmingContent)
              WarningActionBarIcon(message: message, isAnonymous: isAnonymous),
          ],
        ),
      ),
    );
  }
}
