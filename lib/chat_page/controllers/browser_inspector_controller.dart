import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_inspector_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_datalayer_content.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_network_content.dart';

class BrowserInspectorController extends GetxController
    with GetTickerProviderStateMixin {
  late TabController tabController;
  RxInt inspectorTabIndex = 0.obs;
  Rxn<ToolUseBrowserUseData> browserUseData = Rxn<ToolUseBrowserUseData>();
  List<Widget> inspectorPages = [
    BrowserUseNetworkContent(),
    BrowserUseDatalayerContent(),
  ];
  TextEditingController searchBarController = TextEditingController();
  RxString searchBarText = "".obs;
  RxList<NetworkItem> searchNetworkItems = <NetworkItem>[].obs;
  RxList<Map<String, dynamic>> searchDatalayerItems =
      <Map<String, dynamic>>[].obs;

  bool get isSearching => searchBarText.trim() != "";

  void openBrowserInspectorModal(ToolUseBrowserUseData data) {
    browserUseData.value = data;
    tabController = TabController(
      length: browserUseData.value?.inspectorTabsCount ?? 0,
      vsync: this,
    );
    inspectorTabIndex.value = 0;
    tabController.animateTo(0);
    inspectorPages.clear();
    if (browserUseData.value?.hasNetwork ?? false) {
      inspectorPages.add(const BrowserUseNetworkContent());
    }
    if (browserUseData.value?.hasDatalayer ?? false) {
      inspectorPages.add(const BrowserUseDatalayerContent());
    }
    resetSearch();
    showBrowserInspectorModal();
    update();
  }

  void changeInspectorTabIndex(int index) {
    if (index == inspectorTabIndex.value) return;
    inspectorTabIndex.value = index;
    resetSearch();
    update();
    tabController.animateTo(index);
  }

  void searchInspector(String? query) {
    switch (inspectorPages[inspectorTabIndex.value]) {
      case BrowserUseNetworkContent():
        searchNetwork(query);
        break;
      case BrowserUseDatalayerContent():
        searchDatalayer(query);
        break;
    }
  }

  void searchNetwork(String? query) {
    if (browserUseData.value == null) return;
    searchBarText.value = query ?? "";
    if (query == null || query.isEmpty) {
      searchNetworkItems.value = browserUseData.value?.networkItems ?? [];
    } else {
      searchNetworkItems.value = browserUseData.value!.networkItems
          .where((NetworkItem networkItem) {
            String elaboratedQuery = query.trim().toLowerCase();
            return (networkItem.url).toLowerCase().trim().contains(
                  elaboratedQuery,
                ) ||
                (networkItem.status).toLowerCase().trim().contains(
                  elaboratedQuery,
                ) ||
                (networkItem.resourceType).toLowerCase().trim().contains(
                  elaboratedQuery,
                ) ||
                (networkItem.method).toLowerCase().trim().contains(
                  elaboratedQuery,
                ) ||
                (networkItem.host).toLowerCase().trim().contains(
                  elaboratedQuery,
                );
          })
          .toList()
          .obs;
    }
    searchNetworkItems.refresh();
    update();
  }

  void searchDatalayer(String? query) {
    if (browserUseData.value == null) return;
    searchBarText.value = query ?? "";
    if (query == null || query.isEmpty) {
      searchDatalayerItems.value = browserUseData.value?.datalayerData ?? [];
    } else {
      searchDatalayerItems.value = browserUseData.value!.datalayerData
          .where((Map<String, dynamic> entry) {
            String elaboratedQuery = query.trim().toLowerCase();
            return entry.keys.any(
              (key) =>
                  key.toLowerCase().trim().contains(elaboratedQuery) ||
                  entry.values.any(
                    (value) => value.toString().toLowerCase().trim().contains(
                      elaboratedQuery,
                    ),
                  ),
            );
          })
          .toList()
          .obs;
    }
    searchNetworkItems.refresh();
    update();
  }

  void resetSearch() {
    searchBarText.value = "";
    searchNetworkItems.value = [];
    searchDatalayerItems.value = [];
    searchBarController.clear();
    BuildContext? safeContext = getSafeModalContext();
    if (safeContext != null) FocusScope.of(safeContext).unfocus();
    update();
  }

  String get searchHint => switch (inspectorPages[inspectorTabIndex.value]) {
    BrowserUseNetworkContent() => Strings.searchNetwork.tr,
    BrowserUseDatalayerContent() => Strings.searchDataLayer.tr,
    _ => Strings.search.tr,
  };
}
