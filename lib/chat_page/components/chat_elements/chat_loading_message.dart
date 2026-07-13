import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_phrase.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tag.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_text.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tool_use.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_web_search.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_loading_message.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/loading_message_model.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ChatLoadingMessage extends GetView<PupauChatController> {
  const ChatLoadingMessage({super.key});

  /// Content shown above [LoadingPhrase]. Null when only the phrase row is used.
  static Widget? _primaryLoadingBody(LoadingMessage loadingMessage) {
    switch (loadingMessage.loadingType) {
      case LoadingType.dots:
        return null;
      case LoadingType.text:
        return LoadingText();
      case LoadingType.browserUse:
        return LoadingBrowserUse(browserAction: loadingMessage.message);
      case LoadingType.webSearch:
        return LoadingWebSearch(loadingMessage: loadingMessage.message);
      case LoadingType.tag:
        return LoadingTag();
      case LoadingType.toolUse:
        final List<ToolLoadingEntry> tools = loadingMessage.tools;
        if (tools.isEmpty) {
          return LoadingToolUse(
            toolName: loadingMessage.message,
            toolKey: loadingMessage.message,
            toolUseType:
                loadingMessage.toolUseType ?? ToolUseType.nativeToolsGeneric,
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: tools
              .map(
                (ToolLoadingEntry tool) => LoadingToolUse(
                  toolName: tool.name,
                  toolKey: tool.key,
                  toolUseType:
                      tool.type ??
                      loadingMessage.toolUseType ??
                      ToolUseType.nativeToolsGeneric,
                ),
              )
              .toList(),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {    
    Theme.of(context);
    return Obx(() {
      final LoadingMessage loadingMessage = controller.loadingMessage.value;
      final Widget? primary = _primaryLoadingBody(loadingMessage);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const SizedBox(height: 8),
          if (primary != null) ...<Widget>[
            primary,
            const SizedBox(height: 8),
            const LoadingPhrase(isStackedBelowPrimary: true),
          ] else
            const LoadingPhrase(),
        ],
      );
    });
  }
}
