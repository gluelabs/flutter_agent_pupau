import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showForkConversationModal() {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    final bool isTablet = DeviceService.isTablet;
    final PupauChatController chatController = Get.find();
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      isTopBarLayerAlwaysVisible: true,
      topBarTitle: ModalTopBarTitle(title: Strings.forkTitle.tr),
      child: Obx(() {
        final String forkConversationTitle =
            chatController.forkConversationTitle.value;
        final bool canFork = forkConversationTitle.trim() != "";
        final bool isForking = chatController.isForking.value;
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
              padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
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
                          isEnabled: !isForking,
                          onPressed: () => Navigator.pop(modalSheetContext),
                        ),
                      ),
                      Expanded(
                        child: CustomButton(
                          text: Strings.continue_.tr,
                          isEnabled: canFork && !isForking,
                          isLoading: isForking,
                          onPressed: () async {
                            if (!canFork || isForking) return;
                            await chatController.forkConversation();
                            if (modalSheetContext.mounted) {
                              Navigator.pop(modalSheetContext);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) {
    return;
  }

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (modalSheetContext) {
      return [page(modalSheetContext)];
    },
  );
}
