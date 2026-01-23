import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/custom_action_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/custom_action_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showCustomActionsModal(List<CustomAction> customActions) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    ChatController controller = Get.find();
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
              child: Text(
                Strings.customActions.tr,
                style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: CloseIcon(),
            )
          ],
        ),
        isTopBarLayerAlwaysVisible: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Obx(() {
                  bool canSendPrompt = !controller.stopIsActive();
                  return Column(
                    children: [
                      if (!canSendPrompt)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          child: Text(
                            Strings.customActionsDisabled.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: MyStyles.pupauTheme(!Get.isDarkMode)
                                    .darkBlue,
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ListView.builder(
                        itemCount: customActions.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => CustomActionCard(
                            customAction: customActions[index]),
                      ),
                    ],
                  );
                }),
              )
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
