import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_network_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/browser_inspector_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/no_data_found_info.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

class BrowserUseNetworkContent extends GetView<BrowserInspectorController> {
  const BrowserUseNetworkContent({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<NetworkItem> networkItems = controller.isSearching
          ? controller.searchNetworkItems
          : controller.browserUseData.value?.networkItems ?? [];
      bool isEmpty = networkItems.isEmpty;
      if (isEmpty) {
        return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: NoDataFoundInfo(text: Strings.noSearchFound.tr),
      );
      }
      return ListView.builder(
          itemCount: networkItems.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) =>
              BrowserUseNetworkItem(networkItem: networkItems[index]));
    });
  }
}
