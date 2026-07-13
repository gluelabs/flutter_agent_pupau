import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class CustomSelectionItem extends StatelessWidget {
  const CustomSelectionItem({
    super.key,
    required this.value,
    this.isSelected = false,
    required this.onTap,
  });

  final String value;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            SizedBox(width: 38),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 16),
              child: isSelected
                  ? Icon(
                      Symbols.check,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
                      size: 22,
                      opticalSize: 1,
                      grade: 150,
                    )
                  : SizedBox(width: 22),
            ),
          ],
        ),
      ),
    );
  }
}
