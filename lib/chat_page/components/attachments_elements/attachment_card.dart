import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_delete_confirm_dialog.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_switch.dart';

class AttachmentCard extends GetView<AttachmentsController> {
  const AttachmentCard({super.key, required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isActive = attachment.active;
    bool isLink = attachment.link != "";
    bool isNote = attachment.type == "NOTE";
    bool isLoadingContent = attachment.isLoadingContent;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.5),
      child: InkWell(
        onTap: () => isNote
            ? controller.openAttachmentNoteModal(attachment)
            : controller.toggleAttachment(attachment, !isActive),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: isActive ? 1 : 0.5,
                child: Row(
                  children: [
                    Icon(
                        isNote
                            ? Symbols.edit_note
                            : isLink
                                ? Symbols.link
                                : FileService.getFileIcon(
                                    extension(attachment.fileName)),
                        size: isTablet ? 42 : 36),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              isLink
                                  ? attachment.link
                                  : basename(attachment.fileName),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w500)),
                          Text(
                            "${Strings.costs.tr}: ${attachment.tokens} tokens",
                            style: TextStyle(
                                fontSize: isTablet ? 14 : 12,
                                fontWeight: isActive
                                    ? FontWeight.normal
                                    : FontWeight.w100),
                          )
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                    Transform.scale(
                        scale: 0.7,
                        child: CustomSwitch(
                            isActive: isActive,
                            onChanged: (bool active) => controller
                                .toggleAttachment(attachment, active))),
                  ],
                ),
              ),
            ),
            isLoadingContent
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : IconButton(
                    onPressed: () => showDeleteConfirmDialog(
                        Strings.resourceDeleteConfirm.tr,
                        () => controller.deleteAttachment(attachment.id)),
                    tooltip: Strings.delete.tr,
                    icon: Icon(Symbols.delete,
                        size: isTablet ? 28 : 24,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm))
          ],
        ),
      ),
    );
  }
}
