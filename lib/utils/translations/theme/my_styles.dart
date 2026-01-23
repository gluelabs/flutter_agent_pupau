import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/skeleton_theme_data.dart';
import 'dark_theme_colors.dart';
import 'my_fonts.dart';
import 'light_theme_colors.dart';
import 'theme_extensions/pupau_theme_data.dart';

class MyStyles {
  // Pupau Theme
  static PupauThemeData pupauTheme(bool isLightTheme) {
    return PupauThemeData(
      accent: isLightTheme ? LightThemeColors.accent : DarkThemeColors.accent,
      blue: isLightTheme ? LightThemeColors.blue : DarkThemeColors.blue,
      darkBlue: isLightTheme
          ? LightThemeColors.darkBlue
          : DarkThemeColors.darkBlue,
      white: isLightTheme ? LightThemeColors.white : DarkThemeColors.white,
      black: isLightTheme ? LightThemeColors.black : DarkThemeColors.black,
      grey: isLightTheme ? LightThemeColors.grey : DarkThemeColors.grey,
      magenta: isLightTheme ? LightThemeColors.magenta : DarkThemeColors.magenta,
      lilac: isLightTheme ? LightThemeColors.lilac : DarkThemeColors.lilac,
      lilacHover: isLightTheme
          ? LightThemeColors.lilacHover
          : DarkThemeColors.lilacHover,
      lilacPressed: isLightTheme
          ? LightThemeColors.lilacPressed
          : DarkThemeColors.lilacPressed,
      blueInfo: isLightTheme
          ? LightThemeColors.blueInfo
          : DarkThemeColors.blueInfo,
      yellowWarning: isLightTheme
          ? LightThemeColors.yellowWarning
          : DarkThemeColors.yellowWarning,
      redAlarm: isLightTheme
          ? LightThemeColors.redAlarm
          : DarkThemeColors.redAlarm,
      green: isLightTheme ? LightThemeColors.green : DarkThemeColors.green,

      codeBackground: isLightTheme
          ? LightThemeColors.codeBackground
          : DarkThemeColors.codeBackground,
      betaPreviewChipBackground: isLightTheme
          ? LightThemeColors.betaPreviewChipBackground
          : DarkThemeColors.betaPreviewChipBackground,
    );
  }

  static SkeletonThemeData getSkeletonThemeData({required bool isLightTheme}) =>
      SkeletonThemeData(
        mainColor: isLightTheme
            ? LightThemeColors.skeletonMainColor
            : DarkThemeColors.skeletonMainColor,
        shimmerColor: isLightTheme
            ? LightThemeColors.skeletonShimmerColor
            : DarkThemeColors.skeletonShimmerColor,
      );

  ///icons theme
  static IconThemeData getIconTheme({required bool isLightTheme}) =>
      IconThemeData(
        color: isLightTheme
            ? LightThemeColors.iconColor
            : DarkThemeColors.iconColor,
      );

  ///text theme
  static TextTheme getTextTheme({required bool isLightTheme}) => TextTheme(
    labelLarge: MyFonts.buttonTextStyle.copyWith(
      inherit: true,
      fontSize: MyFonts.buttonTextSize,
      fontFamily: 'Poppins',
      color: isLightTheme
          ? LightThemeColors.bodyTextColor
          : DarkThemeColors.bodyTextColor,
    ),
    bodyLarge: (MyFonts.bodyTextStyle).copyWith(
      inherit: true,
      fontSize: MyFonts.bodyLargeSize,
      fontFamily: 'Poppins',
      color: isLightTheme
          ? LightThemeColors.bodyTextColor
          : DarkThemeColors.bodyTextColor,
    ),
    bodyMedium: (MyFonts.bodyTextStyle).copyWith(
      inherit: true,
      fontSize: MyFonts.bodyMediumSize,
      fontFamily: 'Poppins',
      color: isLightTheme
          ? LightThemeColors.bodyTextColor
          : DarkThemeColors.bodyTextColor,
    ),
    displayLarge: (MyFonts.displayTextStyle).copyWith(
      inherit: true,
      fontSize: MyFonts.displayLargeSize,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.bold,
      color: isLightTheme
          ? LightThemeColors.displayTextColor
          : DarkThemeColors.displayTextColor,
    ),
    bodySmall: TextStyle(
      inherit: true,
      fontFamily: 'Poppins',
      color: isLightTheme
          ? LightThemeColors.bodySmallTextColor
          : DarkThemeColors.bodySmallTextColor,
      fontSize: MyFonts.bodySmallTextSize,
    ),
    displayMedium: (MyFonts.displayTextStyle).copyWith(
      inherit: true,
      fontFamily: 'Poppins',
      fontSize: MyFonts.displayMediumSize,
      fontWeight: FontWeight.bold,
      color: isLightTheme
          ? LightThemeColors.displayTextColor
          : DarkThemeColors.displayTextColor,
    ),
    displaySmall: (MyFonts.displayTextStyle).copyWith(
      inherit: true,
      fontFamily: 'Poppins',
      fontSize: MyFonts.displaySmallSize,
      fontWeight: FontWeight.bold,
      color: isLightTheme
          ? LightThemeColors.displayTextColor
          : DarkThemeColors.displayTextColor,
    ),
  );

  // elevated button text style
  static WidgetStateProperty<TextStyle?>? getElevatedButtonTextStyle(
    bool isLightTheme, {
    bool isBold = true,
    double? fontSize,
  }) {
    return WidgetStateProperty.resolveWith<TextStyle>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.pressed)) {
        return MyFonts.buttonTextStyle.copyWith(
          inherit: true,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontSize: fontSize ?? MyFonts.buttonTextSize,
          fontFamily: 'Poppins',
          color: isLightTheme
              ? LightThemeColors.buttonTextColor
              : DarkThemeColors.buttonTextColor,
        );
      } else if (states.contains(WidgetState.disabled)) {
        return MyFonts.buttonTextStyle.copyWith(
          inherit: true,
          fontSize: fontSize ?? MyFonts.buttonTextSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontFamily: 'Poppins',
          color: isLightTheme
              ? LightThemeColors.buttonDisabledTextColor
              : DarkThemeColors.buttonDisabledTextColor,
        );
      }
      return MyFonts.buttonTextStyle.copyWith(
        inherit: true,
        fontSize: fontSize ?? MyFonts.buttonTextSize,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Poppins',
        color: isLightTheme
            ? LightThemeColors.buttonTextColor
            : DarkThemeColors.buttonTextColor,
      ); // Use the component's default.
    });
  }

  //elevated button theme data
  static ElevatedButtonThemeData getElevatedButtonTheme({
    required bool isLightTheme,
  }) => ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          //side: BorderSide(color: Colors.teal, width: 2.0),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(vertical: 8),
      ),
      textStyle: getElevatedButtonTextStyle(isLightTheme),
      backgroundColor: WidgetStateProperty.resolveWith<Color>((
        Set<WidgetState> states,
      ) {
        if (states.contains(WidgetState.pressed)) {
          return isLightTheme
              ? LightThemeColors.buttonColor.withValues(alpha: 0.5)
              : DarkThemeColors.buttonColor.withValues(alpha: 0.5);
        } else if (states.contains(WidgetState.disabled)) {
          return isLightTheme
              ? LightThemeColors.buttonDisabledColor
              : DarkThemeColors.buttonDisabledColor;
        }
        return isLightTheme
            ? LightThemeColors.buttonColor
            : DarkThemeColors.buttonColor; // Use the component's default.
      }),
    ),
  );

  /// list tile theme data
  static ListTileThemeData getListTileThemeData({required bool isLightTheme}) {
    return ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      iconColor: isLightTheme
          ? LightThemeColors.listTileIconColor
          : DarkThemeColors.listTileIconColor,
      tileColor: isLightTheme
          ? LightThemeColors.listTileBackgroundColor
          : DarkThemeColors.listTileBackgroundColor,
      titleTextStyle: TextStyle(
        fontSize: MyFonts.listTileTitleSize,
        color: isLightTheme
            ? LightThemeColors.listTileTitleColor
            : DarkThemeColors.listTileTitleColor,
      ),
      subtitleTextStyle: TextStyle(
        fontSize: MyFonts.listTileSubtitleSize,
        color: isLightTheme
            ? LightThemeColors.listTileSubtitleColor
            : DarkThemeColors.listTileSubtitleColor,
        fontFamily: 'Poppins',
      ),
    );
  }
}
