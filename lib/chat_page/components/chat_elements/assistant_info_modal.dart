import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_capabilities.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/info_row.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showAssistantInfoModal(Assistant assistant) {
  bool isTablet = DeviceService.isTablet;
  bool isMarketplace = assistant.type == AssistantType.marketplace;
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalSheetContext).viewInsets.bottom,
        ),
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Padding(
              padding: EdgeInsets.only(top: isTablet ? 0 : 35, bottom: 15),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isTablet) const CloseIcon(),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        bottom: isTablet ? 10 : 0,
                      ),
                      child: SizedBox(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 4,
                              child: AssistantAvatar(
                                assistantId: assistant.id,
                                imageUuid: assistant.imageUuid,
                                radius: isTablet ? 80 : 60,
                                format: ImageFormat.high,
                                isMarketplaceUrl: isMarketplace,
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  right: 20,
                                  bottom: 12,
                                  top: 12,
                                ),
                                child: Text(
                                  assistant.name,
                                  overflow: TextOverflow.visible,
                                  maxLines: 5,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: isTablet ? 24 : 16,
                                    fontWeight: FontWeight.w500,
                                    color: MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).darkBlue,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InfoRow(
                            title: Strings.model.tr,
                            info: assistant.model?.name ?? "",
                          ),
                        ),
                        if (assistant.costMessage != "")
                          Expanded(
                            child: InfoRow(
                              title:
                                  "${Strings.cost.tr} (${Strings.credits.tr.toLowerCase()})",
                              info:
                                  "${StringService.removeTrailingZeros(assistant.costMessage)}/${Strings.messageAbbreviation.tr}",
                            ),
                          ),
                      ],
                    ),
                    AssistantCapabilities(assistant: assistant),
                    InfoRow(
                      title: Strings.description.tr,
                      info: assistant.description,
                      topPadding: 6,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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
