import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MarketplaceIcon extends StatelessWidget {
  const MarketplaceIcon({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Tooltip(
      message: Strings.marketplace.tr,
      child: Icon(
        Symbols.local_mall,
        color: color ?? MyStyles.pupauTheme(!Get.isDarkMode).accent,
        size: isTablet ? 17 : 15,
      ),
    );
  }
}
