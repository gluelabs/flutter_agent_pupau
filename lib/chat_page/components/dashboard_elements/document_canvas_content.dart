import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/attachment_canvas_content.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class DocumentCanvasContent extends StatelessWidget {
  const DocumentCanvasContent({super.key, required this.document});

  final DocumentData document;

  @override
  Widget build(BuildContext context) {
    final Attachment? attachment = document.relatedAttachment;
    if (attachment == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '${document.fileName} (${Strings.documentDeleted.tr})',
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
      );
    }
    return AttachmentCanvasContent(attachment: attachment);
  }
}
