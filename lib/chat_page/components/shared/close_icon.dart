import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class CloseIcon extends StatelessWidget {
  const CloseIcon({super.key, this.onPressed, this.shouldPop = true});

  final void Function()? onPressed;
  final bool shouldPop;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(right: 8, top: 8),
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          borderRadius: const BorderRadius.all(Radius.circular(100)),
          color: Colors.transparent,
          child: IconButton(
            icon: const Icon(Symbols.close),
            iconSize: isTablet ? 32 : 24,
            color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
            tooltip: Strings.back.tr,
            onPressed: () {
              onPressed?.call();
              if (shouldPop) Navigator.of(context).pop();
            },
          ),
        ),
      ),
    );
  }
}
