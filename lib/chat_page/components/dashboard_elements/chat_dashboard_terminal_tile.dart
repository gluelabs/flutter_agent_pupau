import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';

/// One-line shell / code interpreter tool row for the "Terminal" dashboard
/// section.
class ChatDashboardTerminalTile extends GetView<ChatDashboardController> {
  const ChatDashboardTerminalTile({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final String label = toolUseMessage.getName();
    return InkWell(
      onTap: () =>
          controller.selectCanvasItem(ToolMessageCanvasItem(toolUseMessage)),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(fontSize: isTablet ? 16 : 14),
        ),
      ),
    );
  }
}
