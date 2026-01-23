import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageLoadErrorInfo extends StatelessWidget {
  const MessageLoadErrorInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    Color redAlarm = MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Row(
        children: [
          Icon(Symbols.error_outline_rounded, color: redAlarm, size: 20),
          SizedBox(width: 6),
          Expanded(
            child: Text(Strings.messageLoadError.tr,
                style: TextStyle(color: redAlarm, fontSize: isTablet ? 16 : 15)),
          ),
        ],
      ),
    );
  }
}
