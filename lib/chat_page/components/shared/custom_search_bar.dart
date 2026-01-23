import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.isIconVisible,
    required this.onIconPressed,
    required this.onChanged,
    this.isVisible = true,
    this.hintText,
    this.icon,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final bool isVisible;
  final bool isIconVisible;
  final Function() onIconPressed;
  final Function(String?) onChanged;
  final String? hintText;
  final IconData? icon;
  final Function(String?)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;

    return Visibility(
      visible: isVisible,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: SizedBox(
          height: 48,
          child: TextFormField(
            style: TextStyle(fontSize: isTablet ? 16 : 14),
            controller: controller,
            decoration: InputDecoration(
                border: StyleService.border(),
                enabledBorder: StyleService.border(),
                focusedBorder: StyleService.focusBorder(),
                disabledBorder: StyleService.border(),
                fillColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
                hintText: hintText ?? "${Strings.search.tr}...",
                hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                suffixIcon: Visibility(
                    visible: isIconVisible,
                    child: IconButton(
                        onPressed: onIconPressed,
                        icon: Icon(icon ?? Symbols.close, size: isTablet ? 26 : 24)))),
            onChanged: (String? value) => onChanged(value),
            onFieldSubmitted: (String? value) => onFieldSubmitted?.call(value),
          ),
        ),
      ),
    );
  }
}
