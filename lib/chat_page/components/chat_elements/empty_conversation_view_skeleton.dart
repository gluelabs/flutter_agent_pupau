import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';

/// Loading placeholder shown in [PupauAgentChat] in place of
/// [EmptyConversationView] while [PupauChatController.isChatEntryResolving]
/// (or [PupauChatController.isLoadingConversation]) is still true — i.e. the
/// chat screen is already open but assistant/conversation data isn't ready
/// yet. Mirrors [EmptyConversationView]'s layout with placeholder content so
/// there's no visual jump once the real data swaps in.
class EmptyConversationViewSkeleton extends StatelessWidget {
  const EmptyConversationViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Skeletonizer(
            enabled: true,
            effect: StyleService.skeletonEffect(Get.isDarkMode),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AssistantAvatar(
                  assistantId: '',
                  imageUuid: '',
                  radius: 26,
                  format: ImageFormat.low,
                ),
                const SizedBox(height: 42),
                const Text(
                  'Assistant name',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  'A placeholder welcome message that wraps across a '
                  'couple of lines while the real one loads in.',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.35),
                ),
                const SizedBox(height: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
