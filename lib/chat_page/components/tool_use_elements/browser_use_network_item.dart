import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class BrowserUseNetworkItem extends StatelessWidget {
  const BrowserUseNetworkItem({
    super.key,
    required this.networkItem,
  });

  final NetworkItem networkItem;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 2,
        children: [
          Row(
            spacing: 8,
            children: [
              Text(networkItem.method,
                  style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
              Text(networkItem.status,
                  style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: networkItem.getStatusColor())),
              Text(networkItem.resourceType,
                  style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w300,
                      color:
                          MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                              .bodyMedium
                              ?.color)),
            ],
          ),
          CustomSelectableText(text: networkItem.url, textStyle: TextStyle(fontSize: isTablet ? 16 : 14, color: MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode).bodyMedium?.color), openLinks: false,),
          CustomSelectableText(text: networkItem.host, textStyle: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w300, color: MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode).bodyMedium?.color), openLinks: false,),
        ],
      ),
    );
  }
}
