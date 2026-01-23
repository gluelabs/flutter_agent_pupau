import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_datalayer_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/browser_inspector_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/no_data_found_info.dart';

class BrowserUseDatalayerContent extends GetView<BrowserInspectorController> {
  const BrowserUseDatalayerContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      bool isSearching = controller.isSearching;
      List<Map<String, dynamic>> datalayerItems = isSearching
          ? controller.searchDatalayerItems
          : controller.browserUseData.value?.datalayerData ?? [];
      bool isEmpty = datalayerItems.isEmpty;
      if (isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: NoDataFoundInfo(text: Strings.noSearchFound.tr),
        );
      }
      return ListView.builder(
        itemCount: datalayerItems.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) =>
            BrowserUseDatalayerItem(datalayerItem: datalayerItems[index]),
      );
    });
  }
}
