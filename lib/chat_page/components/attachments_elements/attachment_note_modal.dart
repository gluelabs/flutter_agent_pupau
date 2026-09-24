import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_view/photo_view.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showAttachmentNoteModal({bool isEditable = true}) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    PupauAttachmentsController controller = Get.find();
    bool isEditMode = controller.openAttachmentNote.value != null;
    final String title = isEditable
        ? (isEditMode ? Strings.editNote.tr : Strings.createNote.tr)
        : (controller.openAttachmentNote.value?.fileName ?? "");

    final Attachment? openAttachment = controller.openAttachmentNote.value;
    final bool isImage = openAttachment != null &&
        AttachmentService.getAttachmentCategory(openAttachment) ==
            AttachmentCategory.image;
    if (isImage) {
      return WoltModalSheetPage(
        hasTopBarLayer: true,
        topBarTitle: ModalTopBarTitle(title: title),
        isTopBarLayerAlwaysVisible: true,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          child: _AttachmentImageView(
            attachmentId: openAttachment.id,
            isTablet: isTablet,
          ),
        ),
      );
    }

    return WoltModalSheetPage(
        hasTopBarLayer: true,
        topBarTitle: ModalTopBarTitle(
          title: title,
        ),
        isTopBarLayerAlwaysVisible: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              CustomInputField(
                  label: Strings.noteName.tr,
                  textController: controller.noteNameController,
                  readOnly: !isEditable,
                  onChange: (String text) => controller.setNoteName(text)),
              CustomInputField(
                  hint: Strings.noteHint.tr,
                  textController: controller.noteContentController,
                  maxlines: 8,
                  readOnly: !isEditable,
                  onChange: (String text) => controller.setNoteContent(text)),
              const SizedBox(height: 24),
              Obx(() {
                bool isEditing = controller.openAttachmentNote.value != null;
                return isEditing
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            IntrinsicWidth(
                              child: CustomButton(
                                horizontalPadding: 8,
                                text: "MD",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "md"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .primary),
                              ),
                            ),
                            IntrinsicWidth(
                              child: CustomButton(
                                horizontalPadding: 8,
                                text: "PDF",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "pdf"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .primary),
                              ),
                            ),
                            IntrinsicWidth(
                              child: CustomButton(
                                horizontalPadding: 8,
                                text: "DOCX",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "docx"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .primary),
                              ),
                            ),
                          ],
                        ),
                    )
                    : const SizedBox();
              }),
              const SizedBox(height: 4),
              if (isEditable)
                SizedBox(
                    width: DeviceService.width,
                    child: Obx(() {
                      bool isEditing =
                          controller.openAttachmentNote.value != null;
                      return CustomButton(
                          text: isEditing ? Strings.save.tr : Strings.create.tr,
                          isLoading: controller.isSavingAttachmentNote.value,
                          isEnabled: controller.canSaveAttachmentNote(),
                          onPressed: () => controller.saveAttachmentNote(modalSheetContext));
                    })),
              if (isTablet) const SizedBox(height: 24)
            ],
          ),
        ));
  }

  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;
  
  showPupauModalSheet(
      context: safeContext,
      pageListBuilder: (modalSheetContext) {
        return [
          page(modalSheetContext),
        ];
      });
}

/// Image-attachment view for the preview modal: pinch-to-zoom picture plus a
/// "save to gallery" action. Bytes come from
/// [PupauAttachmentsController.canvasImageBytes], populated by
/// [PupauAttachmentsController.openAttachmentNoteModal] for image attachments.
class _AttachmentImageView extends GetView<PupauAttachmentsController> {
  const _AttachmentImageView({required this.attachmentId, required this.isTablet});

  final String attachmentId;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final double previewHeight = isTablet ? 460 : 320;

    return Obx(() {
      final bool isLoading = controller.attachmentIdsLoadingNoteModal.contains(
        attachmentId,
      );
      final Uint8List? bytes = controller.canvasImageBytes.value;

      Widget preview;
      if (isLoading) {
        preview = Skeletonizer(
          enabled: true,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const SizedBox.expand(),
          ),
        );
      } else if (bytes == null) {
        preview = const ImageNotAvailableWidget();
      } else {
        preview = ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoView(
            imageProvider: MemoryImage(bytes),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.contained * 4.0,
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
            errorBuilder: (context, error, stackTrace) =>
                const ImageNotAvailableWidget(),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: previewHeight, width: double.infinity, child: preview),
          const SizedBox(height: 16),
          SizedBox(
            width: DeviceService.width,
            child: CustomButton(
              text: Strings.download.tr,
              isEnabled: bytes != null,
              onPressed: () {
                final Uint8List? current = controller.canvasImageBytes.value;
                if (current != null) {
                  FileService.downloadBase64Image(base64Encode(current));
                }
              },
              icon: Icon(
                Symbols.download,
                color: MyStyles.pupauTheme(!Get.isDarkMode).white,
              ),
            ),
          ),
        ],
      );
    });
  }
}
