import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/web_search_canvas_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_browser_use.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_code_interpreter.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_mail.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_native_database.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_shell_tool.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/smtp_tool_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info_list.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class ToolCanvasContent extends StatelessWidget {
  const ToolCanvasContent({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return switch (toolUseMessage.type) {
      ToolUseType.nativeToolsMail => PaddedContent(
        child: MessageMail(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
      ToolUseType.nativeToolsSMTP => SMTPToolContent(
        smtpData: toolUseMessage.smtpData,
      ),
      ToolUseType.nativeToolsWebSearch => WebSearchCanvasContent(
        toolUseMessage: toolUseMessage,
      ),
      ToolUseType.nativeToolsBrowserUse => PaddedContent(
        child: MessageBrowserUse(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
      ToolUseType.nativeToolsNativeDatabase => PaddedContent(
        child: MessageNativeDatabase(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
      ToolUseType.nativeToolsShell => PaddedContent(
        child: MessageShellTool(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
      ToolUseType.nativeToolsCodeInterpreter => PaddedContent(
        child: MessageCodeInterpreter(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
      ToolUseType.remoteCall => PaddedContent(
        child: ToolUseInfoList(
          infoList: toolUseMessage.remoteCallData ?? <String, dynamic>{},
          isAnonymous: isAnonymous,
          forceExpanded: true,
        ),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class PaddedContent extends StatelessWidget {
  const PaddedContent({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}
