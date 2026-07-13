import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/attachment_canvas_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/document_canvas_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/tool_canvas_content.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';

/// Renders the full content of a dashboard canvas item inline.
class DashboardCanvasContent extends StatelessWidget {
  const DashboardCanvasContent({
    super.key,
    required this.item,
    required this.isAnonymous,
  });

  final DashboardCanvasItem item;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      ToolMessageCanvasItem(:final ToolUseMessage toolUseMessage) =>
        ToolCanvasContent(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      DocumentCanvasItem(:final DocumentData document) => DocumentCanvasContent(
        document: document,
      ),
      AttachmentCanvasItem(:final Attachment attachment) =>
        AttachmentCanvasContent(attachment: attachment),
    };
  }
}
