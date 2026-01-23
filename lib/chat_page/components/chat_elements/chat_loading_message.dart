import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_dots.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tag.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_text.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tool_use.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_web_search.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_loading_message.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/loading_message_model.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ChatLoadingMessage extends GetView<ChatController> {
  const ChatLoadingMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      LoadingMessage loadingMessage = controller.loadingMessage.value;
      switch (loadingMessage.loadingType) {
        case LoadingType.dots:
          return const LoadingDots();
        case LoadingType.text:
          return LoadingText();
        case LoadingType.browserUse:
          return LoadingBrowserUse(browserAction: loadingMessage.message);
        case LoadingType.webSearch:
          return LoadingWebSearch(loadingMessage: loadingMessage.message);
        case LoadingType.tag:
          return LoadingTag();
        case LoadingType.toolUse:
          return LoadingToolUse(
              toolName: loadingMessage.message,
              toolUseType:
                  loadingMessage.toolUseType ?? ToolUseType.nativeToolsGeneric);
        default:
          return const LoadingDots();
      }
    });
  }
}
