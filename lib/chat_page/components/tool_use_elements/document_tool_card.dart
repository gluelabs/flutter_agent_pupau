import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';

class DocumentToolCard extends GetView<AttachmentsController> {
  const DocumentToolCard({
    super.key,
    required this.document,
  });

  final DocumentData document;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    Attachment? attachment = document.relatedAttachment;
    return attachment == null
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              "${document.fileName} (${Strings.documentDeleted.tr})",
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w300,
              ),
            ),
          )
        : InkWell(
            onTap: () => controller.openAttachmentNoteModal(attachment,
                isEditable: false),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Symbols.edit_note, size: isTablet ? 26 : 24),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${attachment.fileName}.${attachment.extension}",
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
