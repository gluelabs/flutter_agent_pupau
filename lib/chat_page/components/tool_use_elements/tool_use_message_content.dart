import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_ask_user.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_browser_use.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_document.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_knowledge_base.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_thinking.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_to_do_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info_list.dart';

class ToolUseMessageContent extends StatelessWidget {
  const ToolUseMessageContent({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isNativeTool = (ToolUseService.isNativeTool(toolUseMessage?.type)) &&
        toolUseMessage?.nativeToolData != null;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: switch (toolUseMessage?.type) {
        ToolUseType.nativeToolsWebSearch ||
        ToolUseType.pipeline ||
        ToolUseType.remoteCall ||
        ToolUseType.nativeToolsDatabase ||
        ToolUseType.nativeToolsSMTP ||
        ToolUseType.nativeToolsGoogleDrive ||
        ToolUseType.nativeToolsWebReader ||
        ToolUseType.nativeToolsPassthrough =>
          SizedBox(),
        ToolUseType.nativeToolsToDoList => MessageToDoList(
            toolUseMessage: toolUseMessage,
            isAnonymous: isAnonymous,
          ),
        ToolUseType.nativeToolsKnowledgeBase =>
          MessageKnowledgeBase(toolUseMessage: toolUseMessage),
        ToolUseType.nativeToolsDocument => MessageDocument(
            toolUseMessage: toolUseMessage,
            isAnonymous: isAnonymous,
          ),
        ToolUseType.nativeToolsBrowserUse => MessageBrowserUse(
            toolUseMessage: toolUseMessage,
            isAnonymous: isAnonymous,
          ),
        ToolUseType.nativeToolsAskUser => MessageAskUser(
            toolUseMessage: toolUseMessage,
            isAnonymous: isAnonymous
          ),
        ToolUseType.nativeToolsThinking => MessageThinking(
            toolUseMessage: toolUseMessage,
            isAnonymous: isAnonymous,
          ),
        _ => isNativeTool
            ? ToolUseInfoList(
                infoList: toolUseMessage?.nativeToolData ?? {},
                isAnonymous: isAnonymous,
                forceExpanded: ToolUseService.isInitiallyExpandedTool(toolUseMessage?.type),
              )
            : const SizedBox.shrink(),
      },
    );
  }
}
