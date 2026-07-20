import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/source_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showOrganicInfoModal(List<OrganicInfo> organicInfo) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.sources.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: ListView.builder(
                itemCount: organicInfo.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) =>
                    SourceInfo(organicInfo: organicInfo[index]),
              ),
            ),
          ],
        ),
      ),
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
