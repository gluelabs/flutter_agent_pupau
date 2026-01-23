import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showForkConversationModal() {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    ChatController chatController = Get.find();
    return WoltModalSheetPage(
        surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        hasTopBarLayer: true,
        isTopBarLayerAlwaysVisible: true,
        topBarTitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 48),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(Strings.forkTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: CloseIcon(),
            )
          ],
        ),
        child: Obx(() {
          String forkConversationTitle =
              chatController.forkConversationTitle.value;
          bool canFork = forkConversationTitle.trim() != "";
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, left: 24, right: 24),
                child: Text(
                  Strings.forkDescription.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: CustomInputField(
                        label: Strings.newConversationTitle.tr,
                        hint: Strings.insertTitle.tr,
                        topPadding: 4,
                        textController:
                            chatController.forkConversationTitleController,
                        onChange: (String value) =>
                            chatController.setForkConversationTitle(value),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      spacing: 25,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: Strings.undo.tr,
                            isPrimary: false,
                            onPressed: () => Navigator.pop(modalSheetContext),
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            text: Strings.continue_.tr,
                            isEnabled: canFork,
                            onPressed: () {
                              chatController.forkConversation();
                              Navigator.pop(modalSheetContext);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }));
  }

  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) {
    return;
  }
  
  WoltModalSheet.show(
      context: safeContext,
      pageListBuilder: (modalSheetContext) {
        return [
          page(modalSheetContext),
        ];
      });
}
