import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/attachment_note_skeleton.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class AttachmentCanvasContent extends GetView<PupauAttachmentsController> {
  const AttachmentCanvasContent({super.key, required this.attachment});

  final Attachment attachment;

  @override
  Widget build(BuildContext context) {
    final bool isEditable = attachment.isEditable;
    final bool isTablet = DeviceService.isTablet;

    return Obx(() {
      final bool isLoading =
          controller.attachmentIdsLoadingNoteModal.contains(attachment.id);

      if (isLoading) {
        return AttachmentNoteSkeleton(isEditable: isEditable);
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomInputField(
              label: Strings.noteName.tr,
              textController: controller.noteNameController,
              readOnly: !isEditable,
              onChange: (String text) => controller.setNoteName(text),
            ),
            CustomInputField(
              hint: Strings.noteHint.tr,
              textController: controller.noteContentController,
              maxlines: 8,
              readOnly: !isEditable,
              onChange: (String text) => controller.setNoteContent(text),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final bool isEditing =
                  controller.openAttachmentNote.value != null;
              if (!isEditing) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    IntrinsicWidth(
                      child: CustomButton(
                        horizontalPadding: 8,
                        text: 'MD',
                        onPressed: () => FileService.saveToDownloads(
                          controller.noteContentController.text,
                          controller.getOpenAttachmentName,
                          'md',
                        ),
                        isPrimary: false,
                        hasBorders: true,
                        icon: Icon(
                          Symbols.download,
                          color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: CustomButton(
                        horizontalPadding: 8,
                        text: 'PDF',
                        onPressed: () => FileService.saveToDownloads(
                          controller.noteContentController.text,
                          controller.getOpenAttachmentName,
                          'pdf',
                        ),
                        isPrimary: false,
                        hasBorders: true,
                        icon: Icon(
                          Symbols.download,
                          color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: CustomButton(
                        horizontalPadding: 8,
                        text: 'DOCX',
                        onPressed: () => FileService.saveToDownloads(
                          controller.noteContentController.text,
                          controller.getOpenAttachmentName,
                          'docx',
                        ),
                        isPrimary: false,
                        hasBorders: true,
                        icon: Icon(
                          Symbols.download,
                          color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 4),
            if (isEditable)
              Obx(
                () => SizedBox(
                  width: DeviceService.width,
                  child: CustomButton(
                    text: controller.openAttachmentNote.value != null
                        ? Strings.save.tr
                        : Strings.create.tr,
                    isLoading: controller.isSavingAttachmentNote.value,
                    isEnabled: controller.canSaveAttachmentNote(),
                    onPressed: () =>
                        controller.saveAttachmentNote(context),
                  ),
                ),
              ),
            if (isTablet) const SizedBox(height: 24),
          ],
        ),
      );
    });
  }
}