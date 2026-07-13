import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_web_search_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:get/get.dart';

/// Dashboard row for web search, web reader, remote API calls, or browser-use tools.
class ChatDashboardWebSectionTile extends GetView<ChatDashboardController> {
  const ChatDashboardWebSectionTile({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    if (toolUseMessage.type == ToolUseType.nativeToolsWebSearch) {
      return ChatDashboardWebSearchTile(toolUseMessage: toolUseMessage);
    }
    final bool isTablet = DeviceService.isTablet;
    final String label = toolUseMessage.getName();
    final IconData icon =
        ToolUseService.getToolUseIcon(toolUseMessage.type) ??
        Icons.bolt_outlined;
    return InkWell(
      onTap: () => _onTap(),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: <Widget>[
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: isTablet ? 16 : 14),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(icon, size: isTablet ? 20 : 18),
            ),
          ],
        ),
      ),
    );
  }

  void _onTap() {
    if (toolUseMessage.type == ToolUseType.nativeToolsWebReader) {
      final String url = toolUseMessage.webReaderData?.url.trim() ?? '';
      if (url.isNotEmpty) DeviceService.openLink(url);
      return;
    }
    controller.selectCanvasItem(ToolMessageCanvasItem(toolUseMessage));
  }
}
