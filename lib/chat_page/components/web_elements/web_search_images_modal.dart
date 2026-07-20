import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/chat_images_list.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showWebSearchImagesModal(List<WebSearchImage> images) {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.images.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 8),
        child: ChatImagesList(
          imagesUrl: images
              .map((WebSearchImage image) => image.imageUrl)
              .toList(),
          hideHeader: true,
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
