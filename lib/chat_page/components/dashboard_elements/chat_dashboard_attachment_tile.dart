import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Conversation attachment row.
/// Only `.md` files can be opened in the canvas — other formats are shown
/// as non-interactive entries (tap disabled, muted appearance).
class ChatDashboardAttachmentTile extends GetView<ChatDashboardController> {
  const ChatDashboardAttachmentTile({super.key, required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final bool canOpen = attachment.extension.toLowerCase() == 'md';
    final bool isEditable = canOpen && attachment.isEditable;
    final Widget row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '${attachment.fileName}.${attachment.extension}',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ),
          if (canOpen)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                isEditable ? Symbols.edit : Symbols.visibility,
                size: isTablet ? 20 : 18,
              ),
            ),
        ],
      ),
    );

    return InkWell(
      onTap: canOpen
          ? () => controller.selectCanvasItem(AttachmentCanvasItem(attachment))
          : null,

      borderRadius: BorderRadius.circular(8),
      child: row,
    );
  }
}
