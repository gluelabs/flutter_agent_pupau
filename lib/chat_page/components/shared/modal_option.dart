import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ModalOption extends StatelessWidget {
  const ModalOption(
      {super.key,
      required this.onTap,
      required this.text,
      required this.icon,
      this.isSelected = false,
      this.isSmall = false,
      this.autoBack = true});

  final Function() onTap;
  final String text;
  final IconData icon;
  final bool isSelected;
  final bool isSmall;
  final bool autoBack;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return InkWell(
      onTap: () {
        if (autoBack) Navigator.pop(context);
        onTap();
      },
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: isSmall ? 6 : 10, horizontal: 12),
        child: Row(
          children: [
            Container(
              width: isTablet
                  ? isSmall
                      ? 46
                      : 60
                  : isSmall
                      ? 36
                      : 50,
              height: isTablet
                  ? isSmall
                      ? 46
                      : 60
                  : isSmall
                      ? 36
                      : 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: MyStyles.pupauTheme(!Get.isDarkMode).blue,
              ),
              child: Icon(
                icon,
                color: MyStyles.pupauTheme(!Get.isDarkMode).white,
                size: isTablet
                    ? isSmall
                        ? 24
                        : 30
                    : isSmall
                        ? 20
                        : 26,
              ),
            ),
            const SizedBox(width: 12.5),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isTablet
                      ? isSmall
                          ? 15
                          : 17
                      : isSmall
                          ? 13
                          : 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Symbols.check,
                    size: isTablet ? 32 : 29,
                    color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
              )
          ],
        ),
      ),
    );
  }
}
