import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';

class ChatDashboardSmtpToolTile extends GetView<ChatDashboardController> {
  const ChatDashboardSmtpToolTile({super.key, required this.toolUseMessage});

  final ToolUseMessage toolUseMessage;

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
              child: Icon(Symbols.outgoing_mail, size: isTablet ? 20 : 18),
            ),
          ],
        ),
      ),
    );
  }
}
