import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachment_switch_skeleton.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_search_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_tokens_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/toggle_attachments_switch.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_info_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_option.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/no_data_found_info.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../shared/close_icon.dart';

void showAttachmentsModal() {
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
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    Strings.contextResources.tr,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Symbols.info,
                    color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                    size: isTablet ? 22 : 20,
                  ),
                  tooltip: Strings.info.tr,
                  onPressed: () => showInfoBox(
                    Strings.contextResources.tr,
                    Strings.contextResourcesInfo.tr,
                  ),
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 8), child: CloseIcon()),
        ],
      ),
      isTopBarLayerAlwaysVisible: true,
      child: Obx(() {
        bool isSearching = controller.searchAttachmentsText.value.trim() != "";
        List<Attachment> attachments = isSearching
            ? controller.filteredAttachments
            : controller.attachments;
        int sendingAttachments = controller.sendingAttachments.value;
        List<Attachment> documentAttachments = attachments
            .where(
              (Attachment attachment) =>
                  AttachmentService.getAttachmentCategory(attachment) ==
                  AttachmentCategory.document,
            )
            .toList();
        List<Attachment> imageAttachments = attachments
            .where(
              (Attachment attachment) =>
                  AttachmentService.getAttachmentCategory(attachment) ==
                  AttachmentCategory.image,
            )
            .toList();
        List<Attachment> linkAttachments = attachments
            .where(
              (Attachment attachment) =>
                  AttachmentService.getAttachmentCategory(attachment) ==
                  AttachmentCategory.link,
            )
            .toList();
        return Column(
          children: [
            ToggleAttachmentsSwitch(),
            AttachmentsSearchBar(),
            AttachmentsList(
              attachments: documentAttachments,
              category: Strings.documents.tr,
            ),
            AttachmentsList(
              attachments: imageAttachments,
              category: Strings.images.tr,
            ),
            AttachmentsList(
              attachments: linkAttachments,
              category: Strings.links.tr,
            ),
            if (sendingAttachments > 0)
              ...List.generate(
                sendingAttachments,
                (_) => const AttachmentCardSkeleton(),
              ),
            if (isSearching && attachments.isEmpty)
              NoDataFoundInfo(text: Strings.noResourcesFound.tr),
            const AttachmentsTokensInfo(),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ModalOption(
                        onTap: () => controller.openAttachmentNoteModal(null),
                        text: Strings.createNote.tr,
                        icon: Symbols.add_notes,
                        isSmall: true,
                        autoBack: false,
                      ),
                    ),
                    Expanded(
                      child: ModalOption(
                        onTap: () => controller.getAttachmentFromCamera(),
                        text: Strings.takePhoto.tr,
                        icon: Symbols.camera_alt,
                        isSmall: true,
                        autoBack: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ModalOption(
                        onTap: () => controller.getAttachmentFromDevice(),
                        text: Strings.browseDevice.tr,
                        icon: Symbols.folder_open,
                        isSmall: true,
                        autoBack: false,
                      ),
                    ),
                    Expanded(
                      child: ModalOption(
                        onTap: () => controller.getAttachmentFromGallery(),
                        text: Strings.browseGallery.tr,
                        icon: Symbols.photo_library,
                        isSmall: true,
                        autoBack: false,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 8),
              ],
            ),
          ],
        );
      }),
    );
  }

  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;
  
  WoltModalSheet.show(
    context: safeContext,
    pageListBuilder: (modalSheetContext) {
      return [page(modalSheetContext)];
    },
  );
}
