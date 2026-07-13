import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/smtp_tool_content.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_s_m_t_p_data.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showSMTPInfoModal(ToolUseMessage toolUseMessage) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    String toolUseName = toolUseMessage.getName();
    ToolUseSMTPData smtpData =
        toolUseMessage.smtpData ??
        ToolUseSMTPData(subject: "", body: "", to: "", cc: "", bcc: "");

    return WoltModalSheetPage(
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: toolUseName),
      isTopBarLayerAlwaysVisible: true,
      child: SMTPToolContent(smtpData: smtpData),
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
