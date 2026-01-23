import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

class StyleService {
  static OutlineInputBorder border() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Get.isDarkMode
          ? Colors.transparent
          : MyStyles.pupauTheme(false).lilacHover,
    ),
  );

  static OutlineInputBorder focusBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(
      color: Get.isDarkMode
          ? Colors.transparent
          : MyStyles.pupauTheme(false).lilacPressed,
    ),
  );

  static Color getBubbleColor(
    bool isAssistant,
    bool isAnonymous,
    bool isCancelled,
  ) => isAssistant
      ? Colors.transparent
      : isAnonymous
      ? AnonymousThemeColors.userBubble.withValues(alpha: isCancelled ? 0.4 : 1)
      : Get.isDarkMode
      ? MyStyles.pupauTheme(
          false,
        ).lilac.withValues(alpha: isCancelled ? 0.4 : 1)
      : MyStyles.pupauTheme(
          true,
        ).darkBlue.withValues(alpha: isCancelled ? 0.4 : 1);

  static BubbleStyle getBubbleStyle(
    bool isAnonymous,
    bool isAssistant,
    bool isCanceled,
  ) {
    return BubbleStyle(
      padding: const BubbleEdges.all(15),
      margin: const BubbleEdges.all(8),
      borderColor: null,
      nipHeight: 18,
      color: getBubbleColor(isAssistant, isAnonymous, isCanceled),
    );
  }

  static ShimmerEffect skeletonEffect(bool isDark) => ShimmerEffect(
    highlightColor: MyStyles.getSkeletonThemeData(
      isLightTheme: !isDark,
    ).shimmerColor,
    baseColor: MyStyles.getSkeletonThemeData(isLightTheme: !isDark).mainColor,
  );

  static TextStyle fieldLabelStyle(bool isDarkMode) => TextStyle(
    color: MyStyles.pupauTheme(!isDarkMode).darkBlue,
    fontSize: DeviceService.isTablet ? 16 : 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle appbarTextStyle(bool isDarkMode) => TextStyle(
      fontSize: DeviceService.isTablet ? 24 : 22,
      fontWeight: FontWeight.w600,
      color: MyStyles.pupauTheme(!isDarkMode).darkBlue,
      height: DeviceService.isTablet ? 1.25 : 1);
}
