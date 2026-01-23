import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BasicAppBar(
      {super.key,
      required this.title,
      this.hasBackground = false,
      this.isArrowWhite = false,
      this.icon,
      this.iconColor,
      this.onPressed,
      this.onBack,
      this.onMenuPressed,
      this.tooltip});

  final String title;
  final bool hasBackground;
  final bool isArrowWhite;
  final IconData? icon;
  final Color? iconColor;
  final Function()? onPressed;
  final Function()? onBack;
  final Function()? onMenuPressed;
  final String? tooltip;
  
  @override
  PreferredSizeWidget build(BuildContext context) {
    Theme.of(context);
    bool isTablet = DeviceService.isTablet;
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      surfaceTintColor: hasBackground
          ? MyStyles.pupauTheme(!Get.isDarkMode).white
          : Colors.transparent,
      backgroundColor: hasBackground
          ? MyStyles.pupauTheme(!Get.isDarkMode).white
          : Colors.transparent,
      title: Padding(
          padding: hasBackground
              ? EdgeInsets.zero
              : EdgeInsets.only(
                  top: 12, right: isTablet ? 6 : 0, left: isTablet ? 6 : 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Symbols.arrow_back_ios),
                  tooltip: Strings.back.tr,
                  color: isArrowWhite
                      ? Colors.white
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                  iconSize: isTablet ? 28 : 24),
              if (title != "")
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(title,
                        style: StyleService.appbarTextStyle(Get.isDarkMode)),
                  ),
                ),
              icon == null || onPressed == null
                  ? const SizedBox(width: 48)
                  : IconButton(
                      onPressed: onPressed,
                      tooltip: tooltip,
                      icon: Icon(icon),
                      color: iconColor ?? (hasBackground ? Colors.white : null),
                      iconSize: isTablet ? 28 : 24),
            ],
          )),
      actions: [
        if (onMenuPressed != null)
          IconButton(
            onPressed: onMenuPressed,
            icon: const Icon(Symbols.menu),
            tooltip: Strings.openDrawer.tr,
            color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
            iconSize: isTablet ? 26 : 24,
          )
        else
          const SizedBox.shrink(),
      ],
      iconTheme: IconThemeData(
          color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          size: isTablet ? 32 : null),
    );
  }

  @override
  Size get preferredSize => hasBackground
      ? Size.fromHeight(DeviceService.isTablet ? 65 : 55)
      : const Size.fromHeight(50);
}
