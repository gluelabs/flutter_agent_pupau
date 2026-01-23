import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showAttachmentNoteModal({bool isEditable = true}) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    AttachmentsController controller = Get.find();
    return WoltModalSheetPage(
        surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        hasTopBarLayer: true,
        topBarTitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Obx(() {
              bool isEditing = controller.openAttachmentNote.value != null;
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                    isEditable
                        ? isEditing
                            ? Strings.editNote.tr
                            : Strings.createNote.tr
                        : controller.openAttachmentNote.value?.fileName ?? "",
                    style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
              );
            }),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: CloseIcon(),
            )
          ],
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
                                horizontalPadding: 4,
                                text: "MD",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "md"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .accent),
                              ),
                            ),
                            IntrinsicWidth(
                              child: CustomButton(
                                horizontalPadding: 4,
                                text: "PDF",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "pdf"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .accent),
                              ),
                            ),
                            IntrinsicWidth(
                              child: CustomButton(
                                horizontalPadding: 4,
                                text: "DOCX",
                                onPressed: () => FileService.saveToDownloads(
                                    controller.noteContentController.text,
                                    controller.getOpenAttachmentName,
                                    "docx"),
                                isPrimary: false,
                                hasBorders: true,
                                icon: Icon(Symbols.download,
                                    color: MyStyles.pupauTheme(!Get.isDarkMode)
                                        .accent),
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
  
  WoltModalSheet.show(
      context: safeContext,
      pageListBuilder: (modalSheetContext) {
        return [
          page(modalSheetContext),
        ];
      });
}
