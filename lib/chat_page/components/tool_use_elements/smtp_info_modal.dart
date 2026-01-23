import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_s_m_t_p_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showSMTPInfoModal(ToolUseMessage toolUseMessage) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    String toolUseName = toolUseMessage.getName();
    ToolUseSMTPData smtpData = toolUseMessage.smtpData ??
        ToolUseSMTPData(subject: "", body: "", to: "", cc: "", bcc: "");

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
              child: Text(toolUseName,
                  style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8),
              child: CloseIcon(),
            )
          ],
        ),
        isTopBarLayerAlwaysVisible: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              ToolUseInfo(
                infoKey: Strings.subject.tr,
                infoValue: smtpData.subject ?? "",
                isAnonymous: false,
                forceExpanded: true,
              ),
              if (smtpData.to != null)
                ToolUseInfo(
                  infoKey: Strings.toEmail.tr.replaceAll("£", ""),
                  infoValue: smtpData.to ?? "",
                  isAnonymous: false,
                  forceExpanded: true,
                ),
              if (smtpData.cc != null)
                ToolUseInfo(
                  infoKey: Strings.ccEmail.tr,
                  infoValue: smtpData.cc ?? "",
                  isAnonymous: false,
                  forceExpanded: true,
                ),
              if (smtpData.bcc != null)
                ToolUseInfo(
                  infoKey: Strings.bccEmail.tr,
                  infoValue: smtpData.bcc ?? "",
                  isAnonymous: false,
                  forceExpanded: true,
                ),
              ToolUseInfo(
                infoKey: Strings.body.tr,
                infoValue: smtpData.body ?? "",
                isAnonymous: false,
                forceExpanded: true,
              ),
              if (isTablet) const SizedBox(height: 24),
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
