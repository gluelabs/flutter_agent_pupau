import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info_list.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showBasicToolUseModal(ToolUseMessage toolUseMessage, bool isAnonymous) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    String toolUseName = toolUseMessage.getName();
    Map<String, dynamic> infoList = toolUseMessage.nativeToolData ?? {};
    if (toolUseMessage.type == ToolUseType.pipeline) {
      infoList = {"message": toolUseMessage.pipelineData?.message};
    } else if (toolUseMessage.type == ToolUseType.remoteCall) {
      infoList = toolUseMessage.remoteCallData ?? {};
    }

    return WoltModalSheetPage(
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: toolUseName),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        child: Column(
          children: [
            ToolUseInfoList(
              infoList: infoList,
              isAnonymous: isAnonymous,
              forceExpanded: true,
            ),
            if (isTablet) const SizedBox(height: 24),
          ],
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
