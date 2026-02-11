import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/chat_audio_label.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_action_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_bottom_elements.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_bubble.dart';
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

class MessageElements extends GetView<ChatController> {
  const MessageElements({
    super.key,
    required this.message,
    this.urls = const [],
    this.isReadOnly = false,
  });

  final PupauMessage message;
  final List<UrlInfo> urls;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    bool isAssistant = message.isMessageFromAssistant;
    Assistant? taggedAssistant = Get.find<AssistantsController>().assistants
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
    bool isToolUse = message.toolUseMessage != null;
    bool isUiTool = message.uiToolMessage != null;
    List<OrganicInfo> organicInfo = message.organicInfo;
    List<WebSearchImage> images = message.images;
    List<WebSearchNews> news = message.news;
    GraphInfo? graphInfo = message.graphInfo;
    List<String> relatedSearches = message.relatedSearches;
    bool showAttachmentBox =
        message.attachments
            .where((attachment) => attachment.link == "")
            .isNotEmpty &&
        !isAssistant;
    bool showBottomElements = isAssistant && !isUiTool && !isToolUse;
    ToolUseMessage? toolUseMessage = message.toolUseMessage;
    toolUseMessage?.messageId = message.id;

    // Only wrap reactive parts in Obx to minimize rebuilds
    return Obx(() {
      bool isAnonymous = controller.isAnonymous;
      bool isLastMessage =
          message ==
          controller.messages.firstOrNull; //messages list is reversed
      bool isActionBarAlwaysVisible =
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
            if (!isAssistant && message.isAudioInput)
              ChatAudioLabel(isAnonymous: isAnonymous),
            isToolUse
                ? ToolUseBubble(message: message.toolUseMessage!)
                : isUiTool
                ? UiToolBubble(message: message.uiToolMessage!)
                : MessageBubble(
                    assistant: taggedAssistant ?? chatAssistant,
                    message: message,
                    isReadOnly: isReadOnly,
                  ),
            if (showBottomElements &&
                isActionBarAlwaysVisible &&
                !message.isInitialMessage &&
                message.status == MessageStatus.received)
              MessageActionBar(message: message),
            if (showBottomElements) MessageBottomElements(message: message),
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
