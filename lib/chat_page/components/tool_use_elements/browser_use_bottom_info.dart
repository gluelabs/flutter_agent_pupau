import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/browser_inspector_controller.dart';

class BrowserUseBottomInfo extends StatelessWidget {
  const BrowserUseBottomInfo({
    super.key,
    required this.browserUseData,
    required this.isAnonymous,
  });

  final ToolUseBrowserUseData? browserUseData;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    TextStyle infoStyle = TextStyle(
        fontSize: isTablet ? 14 : 12,
        color: isAnonymous ? Colors.white : Get.theme.textTheme.bodyMedium?.color);
    int actualWidth = browserUseData?.actualWidth ?? 0;
    int actualHeight = browserUseData?.actualHeight ?? 0;
    String executionTime = browserUseData?.executionTime ?? "0";
    bool hasNoInfo =
        actualWidth == 0 && actualHeight == 0 && executionTime == "0";
    return hasNoInfo
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (actualWidth > 0 && actualHeight > 0)
                      Text(
                          "${Strings.resolution.tr}: $actualWidth x $actualHeight",
                          style: infoStyle),
                    if (executionTime != "0")
                      Text(
                          "${Strings.executionTime.tr}: $executionTime ${Strings.seconds.tr}",
                          style: infoStyle),
                  ],
                ),
                if (browserUseData != null &&
                    browserUseData?.getBrowserUseAction() ==
                        BrowserAction.navigate &&
                    browserUseData!.inspectorTabsCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                        onPressed: () {
                          BrowserInspectorController controller =
                              Get.put(BrowserInspectorController());
                          controller.openBrowserInspectorModal(browserUseData!);
                        },
                        iconSize: isTablet ? 30 : 28,
                        color: isAnonymous ? Colors.white : MyStyles.pupauTheme(!Get.isDarkMode).accent,
                        tooltip: Strings.inspectBrowser.tr,
                        icon: Icon(Symbols.troubleshoot)),
                  )
              ],
            ),
          );
  }
}
