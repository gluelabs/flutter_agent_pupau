import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ScrollButton extends StatelessWidget {
  const ScrollButton(
      {super.key,
      required this.toBottom,
      required this.isVisible,
      required this.onTap,
      this.isAnonymous = false});

  final bool toBottom;
  final bool isVisible;
  final Function() onTap;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Visibility(
      visible: isVisible,
      child: Align(
        alignment: toBottom ? Alignment.bottomRight : Alignment.topRight,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              width: isTablet ? 48 : 38,
              height: isTablet ? 48 : 38,
              decoration: BoxDecoration(
                  color: isAnonymous
                      ? AnonymousThemeColors.assistantBubble
                      : Get.isDarkMode
                          ? MyStyles.pupauTheme(false).magenta
                          : MyStyles.pupauTheme(true).lilac,
                  shape: BoxShape.circle),
              child:
                  Icon(toBottom ? Symbols.arrow_downward : Symbols.arrow_upward,
                      size: isTablet ? 32 : 24,
                      color: isAnonymous
                          ? AnonymousThemeColors.assistantText
                          : Get.isDarkMode
                              ? MyStyles.pupauTheme(false).lilacPressed
                              : MyStyles.pupauTheme(true).darkBlue),
            ),
          ),
        ),
      ),
    );
  }
}
