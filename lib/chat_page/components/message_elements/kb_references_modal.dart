import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/reference_text.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showKBReferencesModal(List<KbReference> references) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.references.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ...references.map((KbReference ref) => ReferenceText(ref: ref)),
            ],
          ),
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
