import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_browser_use_loading_placeholder.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_browser_use_navigate.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_browser_use_screenshot.dart';

class MessageBrowserUse extends GetView<ChatController> {
  const MessageBrowserUse({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    BrowserAction action = toolUseMessage?.browserUseData?.getBrowserUseAction() ?? BrowserAction.navigate;
    if(toolUseMessage?.browserUseData?.isLoadingPlaceholder ?? false) {
      return MessageBrowserUseLoadingPlaceholder(toolUseMessage: toolUseMessage, isAnonymous: isAnonymous);
    }
    switch (action) {
      case BrowserAction.screenshot:
        return MessageBrowserUseScreenshot(toolUseMessage: toolUseMessage, isAnonymous: isAnonymous);
      case BrowserAction.navigate:
        return MessageBrowserUseNavigate(toolUseMessage: toolUseMessage, isAnonymous: isAnonymous);
    }
  }
}