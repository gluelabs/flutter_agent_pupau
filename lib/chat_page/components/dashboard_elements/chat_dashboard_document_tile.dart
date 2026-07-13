import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

/// Single-line document label for the chat dashboard.
/// Documents are read-only entries — they are never tappable.
/// Attachments that duplicate a document are deduplicated upstream and shown
/// in the attachments section instead.
class ChatDashboardDocumentTile extends StatelessWidget {
  const ChatDashboardDocumentTile({super.key, required this.document});

  final DocumentData document;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final Attachment? attachment = document.relatedAttachment;

    final String label = attachment != null
        ? '${attachment.fileName}.${attachment.extension}'
        : '${document.fileName} (${Strings.documentDeleted.tr})';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight:
                    attachment != null ? FontWeight.normal : FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
