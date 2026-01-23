import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_bubble.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class LoadingBrowserUse extends StatelessWidget {
  const LoadingBrowserUse({
    super.key,
    required this.browserAction,
  });

  final String browserAction;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 4, left: 10, right: 10),
        child: ToolUseBubble(
            message: ToolUseService.getBrowserLoadingMessage(browserAction)));
  }
}
