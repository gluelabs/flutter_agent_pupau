import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/no_data_found_info.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showCustomSelectionModal({
  required String title,
  required List<Widget> items,
   Widget? stickyActionBar
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
        surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        hasTopBarLayer: true,
        isTopBarLayerAlwaysVisible: true,
        stickyActionBar: stickyActionBar,
        topBarTitle: ModalTopBarTitle(title: title),
        child: Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: Padding(
            padding: EdgeInsets.only(bottom: stickyActionBar != null ? 58 : 0),
            child: items.isEmpty
                ? NoDataFoundInfo(text: Strings.noItemsFound.tr)
                : ListView.builder(
                  itemCount: items.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) => items[index],
                ),
          ),
        ));
  }

  WoltModalSheet.show(
      context: Get.context!,
      pageListBuilder: (modalSheetContext) {
        return [
          page(modalSheetContext),
        ];
      });
}
