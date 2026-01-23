import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';

class BrowserUseDatalayerItem extends StatelessWidget {
  const BrowserUseDatalayerItem({
    super.key,
    required this.datalayerItem,
  });

  final Map<String, dynamic> datalayerItem;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
          itemCount: datalayerItem.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final entry = datalayerItem.entries.elementAt(index);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSelectableText(
                    text: entry.key == "0"
                        ? "key: "
                        : entry.key == "1"
                            ? "value: "
                            : "${entry.key}: ",
                    openLinks: false,
                    textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                        color:
                            MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                                .bodyMedium
                                ?.color)),
                const SizedBox(width: 4),
                Flexible(
                  child: CustomSelectableText(
                      text: entry.value.toString(),
                      openLinks: false,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: isTablet ? 16 : 14,
                      )),
                ),
                const SizedBox(height: 8), // Add spacing between items
              ],
            );
          }),
    );
  }
}
