import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/browser_inspector_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_search_bar.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showBrowserInspectorModal() {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    bool isTablet = DeviceService.isTablet;
    BrowserInspectorController controller = Get.find<BrowserInspectorController>();
    return WoltModalSheetPage(
        surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        navBarHeight: isTablet ? 104 : 102,
        forceMaxHeight: false,
        hasTopBarLayer: true,
        topBarTitle: Column(
          children: [
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(Strings.inspectBrowser.tr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: MyStyles.pupauTheme(!Get.isDarkMode)
                                .darkBlue))),
                  
                ),
                CloseIcon(
                  onPressed: () => controller.changeInspectorTabIndex(0),
                )
              ],
            ),
            const SizedBox(height: 8),
            TabBar(
              indicatorColor: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
              labelColor: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
              dividerHeight: 0,
              tabs: [
                if(controller.browserUseData.value?.hasNetwork ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    Strings.network.tr,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                ),
                if(controller.browserUseData.value?.hasDatalayer ?? false)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    Strings.dataLayer.tr,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                ),
              ],
              controller: controller.tabController,
              onTap: (index) => controller.changeInspectorTabIndex(index),
            ),
          ],
        ),
        isTopBarLayerAlwaysVisible: true,
        child: Obx(() {
          int currentIndex = controller.inspectorTabIndex.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: controller.searchBarController,
                  isIconVisible: controller.isSearching,
                  onIconPressed: () => controller.resetSearch(),
                  onChanged: (value) => controller.searchInspector(value),
                  hintText: "${controller.searchHint}...",
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  child: controller.inspectorPages[currentIndex]
                ),
              ],
            ),
          );
        }));
  }

  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;
  
  WoltModalSheet.show(
      context: safeContext,
      pageListBuilder: (modalSheetContext) {
        return [page(modalSheetContext)];
      });
}
