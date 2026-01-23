import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class AskUserOption extends StatelessWidget {
  const AskUserOption({
    super.key,
    required this.option,
    required this.isSelected,
    required this.isAnonymous,
    required this.onTap,
    this.isSuggested = false,
  });

  final String option;
  final bool isSelected;
  final bool isAnonymous;
  final Function() onTap;
  final bool isSuggested;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Material(
      color: isSelected
          ? MyStyles.pupauTheme(!Get.isDarkMode)
              .lilacPressed
              .withValues(alpha: 0.75)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isAnonymous
                    ? AnonymousThemeColors.userBubble
                    : Get.isDarkMode
                        ? MyStyles.pupauTheme(false).lilac
                        : MyStyles.pupauTheme(true).grey),
          ),
          child: Text(
            option + (isSuggested ? "*" : ""),
            style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isAnonymous
                    ? isSelected
                        ? Colors.white
                        : AnonymousThemeColors.userBubble
                    : isSelected
                        ? Get.isDarkMode
                            ? MyStyles.pupauTheme(false).lilacPressed
                            : MyStyles.pupauTheme(true).black
                        : Get.isDarkMode
                            ? MyStyles.pupauTheme(false).lilac
                            : MyStyles.pupauTheme(true).grey),
          ),
        ),
      ),
    );
  }
}
