import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {super.key,
      required this.text,
      this.subtext,
      this.icon,
      this.isEnabled = true,
      this.isPrimary = true,
      this.isWarning = false,
      this.isLoading = false,
      this.iconIsLeft = true,
      this.horizontalPadding = 12.5,
      required this.onPressed,
      this.textStyle,
      this.forceDarkMode = false,
      this.hasBorders = false});

  final String text;
  final String? subtext;
  final Widget? icon;
  final bool isEnabled;
  final bool isPrimary;
  final bool isWarning;
  final bool isLoading;
  final bool iconIsLeft;
  final double horizontalPadding;
  final Function() onPressed;
  final TextStyle? textStyle;
  final bool forceDarkMode;
  final bool hasBorders;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    Color textColor = (isPrimary
            ? MyStyles.pupauTheme(!Get.isDarkMode).white
            : isWarning
                ? MyStyles.pupauTheme(forceDarkMode ? false : !Get.isDarkMode)
                    .redAlarm
                : MyStyles.pupauTheme(forceDarkMode ? false : !Get.isDarkMode)
                    .accent)
        .withValues(alpha: !isEnabled && !isPrimary ? 0.35 : 1);
    Color disabledBackgroundColor = isPrimary && !isWarning
        ? const Color(0xffcecece)
        : isPrimary && isWarning
            ? const Color(0xfff99f99)
            : Colors.transparent;
    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: !isPrimary
          ? ElevatedButton.styleFrom(
              elevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              overlayColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(hasBorders ? 10 : 0),
              ),
              side: hasBorders
                  ? BorderSide(
                      color: textColor,
                      width: 1,
                    )
                  : null,
              disabledBackgroundColor: disabledBackgroundColor)
          : ElevatedButton.styleFrom(
              backgroundColor: isWarning
                  ? MyStyles.pupauTheme(forceDarkMode ? false : !Get.isDarkMode)
                      .redAlarm
                  : MyStyles.pupauTheme(forceDarkMode ? false : !Get.isDarkMode)
                      .accent,
              disabledBackgroundColor: disabledBackgroundColor),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: textColor))
            : icon == null
                ? RichText(
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                    text: TextSpan(
                      style: textStyle ??
                          TextStyle(
                              color: textColor,
                              fontSize: isTablet ? 18 : 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins"),
                      children: [
                        TextSpan(text: text),
                        if (subtext != null)
                          TextSpan(
                            text: ' ${subtext!}',
                            style: TextStyle(
                                color: textColor,
                                fontSize: isTablet ? 16 : 12,
                                fontFamily: "Poppins"),
                          ),
                      ],
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (iconIsLeft)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: icon!,
                        ),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: textStyle ??
                            TextStyle(
                                color: textColor,
                                fontFamily: "Poppins",
                                fontSize: isTablet ? 18 : 14),
                      ),
                      if (!iconIsLeft)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: icon!,
                        )
                    ],
                  ),
      ),
    );
  }
}
