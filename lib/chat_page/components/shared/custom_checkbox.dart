import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox(
      {super.key,
      required this.enabled,
      required this.onTap,
      required this.text,
      this.size = 24,
      this.interactable = true});

  final bool enabled;
  final Function() onTap;
  final String text;
  final double size;
  final bool interactable;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: interactable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Row(children: [
            Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                  borderRadius: BorderRadius.circular(6),
                  color: enabled
                      ? MyStyles.pupauTheme(!Get.isDarkMode).darkBlue
                      : MyStyles.pupauTheme(!Get.isDarkMode).white,
                ),
                child: enabled
                    ? Icon(Symbols.check,
                        size: size >= 9 ? size - 8 : size,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).white)
                    : null),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isTablet ? 16 : 14),
                  maxLines: 3),
            )
          ]),
        ),
      ),
    );
  }
}
