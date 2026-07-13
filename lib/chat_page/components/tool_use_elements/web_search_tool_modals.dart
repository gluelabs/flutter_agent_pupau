import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_web_search_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/organic_info_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_images_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_news_modal.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Opens the same web-search result modals as [ToolUseBubble.tapToolUse].
/// When only a query is present (no organic/images/news), shows a simple
/// preview sheet so dashboard rows remain tappable.
void openWebSearchToolModals(ToolUseMessage message) {
  if (message.type != ToolUseType.nativeToolsWebSearch) {
    return;
  }
  final ToolUseWebSearchData? data = message.webSearchData;
  if (data == null) {
    return;
  }
  final List<OrganicInfo> organicInfo = data.organicInfo;
  if (organicInfo.isNotEmpty) {
    showOrganicInfoModal(organicInfo);
  }
  final List<WebSearchImage> images = data.images;
  if (images.isNotEmpty) {
    showWebSearchImagesModal(images);
  }
  final List<WebSearchNews> news = data.news;
  if (news.isNotEmpty) {
    showWebSearchNewsModal(news);
  }
  if (organicInfo.isEmpty &&
      images.isEmpty &&
      news.isEmpty &&
      data.query.trim().isNotEmpty) {
    _showWebSearchQueryOnlyModal(data.query.trim());
  }
}

void _showWebSearchQueryOnlyModal(String query) {
  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) {
    return;
  }
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.webSearch.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: SelectableText(
          query,
          style: Theme.of(modalSheetContext).textTheme.bodyLarge,
        ),
      ),
    );
  }

  WoltModalSheet.show(
    context: safeContext,
    pageListBuilder: (BuildContext modalSheetContext) {
      return <WoltModalSheetPage>[page(modalSheetContext)];
    },
  );
}