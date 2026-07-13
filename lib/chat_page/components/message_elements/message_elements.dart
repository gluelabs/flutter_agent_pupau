import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/chat_audio_label.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/retry_send_audio_button.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_action_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_bottom_elements.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_bubble.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/skill_event_bubble.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/skills_loaded_badge.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/related_searches_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/search_external_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/urls_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_bubble.dart';
import 'package:flutter_agent_pupau/chat_page/components/ui_tool_elements/ui_tool_bubble.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_elements.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';

class MessageElements extends GetView<PupauChatController> {
  const MessageElements({
    super.key,
    required this.message,
    this.urls = const [],
    this.isReadOnly = false,
    this.isConversationLatestMessageOverride,
  });

  final PupauMessage message;
  final List<UrlInfo> urls;
  final bool isReadOnly;

  /// When non-null, used for related-search / "last message" UI instead of
  /// comparing [message] to [PupauChatController.messages.firstOrNull].
  final bool? isConversationLatestMessageOverride;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isAssistant = message.isMessageFromAssistant;
    Assistant? taggedAssistant = Get.find<PupauAssistantsController>()
        .assistants
        .firstWhereOrNull(
          (Assistant assistant) =>
              assistant.id == message.assistantId &&
              assistant.type == message.assistantType,
        );
    Assistant? chatAssistant = controller.assistant.value;
    if (chatAssistant?.id == taggedAssistant?.id &&
        chatAssistant?.type == taggedAssistant?.type) {
      taggedAssistant = null;
    }
    final bool isToolUse = message.toolUseMessage != null;
    final bool isUiTool = message.uiToolMessage != null;
    final List<OrganicInfo> organicInfo = message.organicInfo;
    final List<WebSearchImage> images = message.images;
    final List<WebSearchNews> news = message.news;
    final GraphInfo? graphInfo = message.graphInfo;
    final List<String> relatedSearches = message.relatedSearches;
    final bool showAttachmentBox =
        message.attachments
            .where((attachment) => attachment.link == "")
            .isNotEmpty &&
        !isAssistant;
    final String answer =
        isAssistant &&
            !isToolUse &&
            !isUiTool &&
            TagService.hasThinkingTag(message.answer)
        ? TagService.stripThinkingForMarkdown(message.answer)
        : message.answer;
    final bool showBottomElements =
        isAssistant &&
        !isUiTool &&
        !isToolUse &&
        answer.trim().isNotEmpty &&
        message.skillEventDetail == null;
    final ToolUseMessage? toolUseMessage = message.toolUseMessage;
    toolUseMessage?.messageId = message.id;

    // Only wrap reactive parts in Obx to minimize rebuilds
    return Obx(() {
      final bool isAnonymous = controller.isAnonymous;
      final bool isLastMessage =
          isConversationLatestMessageOverride ??
          (message == controller.messages.firstOrNull);
      final bool isActionBarAlwaysVisible =
          controller.isActionBarAlwaysVisible.value && !isReadOnly;

      return Container(
        padding: EdgeInsets.only(top: 4),
        margin: EdgeInsets.only(
          right: isAssistant ? 10 : 0,
          left: isAssistant ? 10 : DeviceService.width * .15,
        ),
        child: Column(
          crossAxisAlignment: isAssistant
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            WebSearchElements(
              organicInfo: organicInfo,
              graphInfo: graphInfo,
              images: images,
              news: news,
              isAnonymous: isAnonymous,
              isCanceled: message.isCancelled,
            ),
            if (!isToolUse &&
                !isUiTool &&
                message.skillEventDetail == null &&
                isAssistant &&
                message.skillsLoaded.isNotEmpty)
              SkillsLoadedBadge(skills: message.skillsLoaded),
            if (!isAssistant && message.isAudioInput)
              ChatAudioLabel(isAnonymous: isAnonymous),
            isToolUse
                ? ToolUseBubble(message: message.toolUseMessage!)
                : isUiTool
                ? UiToolBubble(message: message.uiToolMessage!)
                : message.skillEventDetail != null
                ? SkillEventBubble(detail: message.skillEventDetail!)
                : MessageBubble(
                    assistant: taggedAssistant ?? chatAssistant,
                    message: message,
                    isReadOnly: isReadOnly,
                  ),
            if (showBottomElements &&
                isActionBarAlwaysVisible &&
                message.status == MessageStatus.received)
              MessageActionBar(message: message),
            if (showBottomElements) MessageBottomElements(message: message),
            if (!isAssistant &&
                message.isAudioInput &&
                message.isCancelled &&
                controller.canRetryAudioMessage(message))
              RetrySendAudioButton(),
            if (relatedSearches.isNotEmpty && isLastMessage)
              RelatedSearchesList(relatedSearches: relatedSearches),
            SearchExternalButton(message: message),
            if (showAttachmentBox)
              AttachmentsBox(attachments: message.attachments),
            if (message.urls.isNotEmpty) UrlsList(urls: message.urls),
          ],
        ),
      );
    });
  }
}
