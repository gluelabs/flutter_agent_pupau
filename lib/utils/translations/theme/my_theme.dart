import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dark_theme_colors.dart';
import 'light_theme_colors.dart';
import 'my_styles.dart';

class MyTheme {
  static ThemeData getThemeData({required bool isLight}) {
    return ThemeData(
      fontFamily: 'Poppins',
      // main color (app bar,tabs..etc)
      primaryColor: isLight
          ? LightThemeColors.primaryColor
          : DarkThemeColors.primaryColor,
      // inputDecoration theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight
            ? LightThemeColors.backgroundColor
            : DarkThemeColors.backgroundColor,
        errorStyle: const TextStyle(height: 0),
        border: defaultInputBorder(isLight),
        enabledBorder: defaultInputBorder(isLight),
        focusedBorder: defaultInputBorder(isLight),
        errorBorder: defaultInputBorder(isLight),
      ),
      // secondary & background color
      colorScheme:
          ColorScheme.fromSwatch(
            accentColor: isLight
                ? LightThemeColors.accentColor
                : DarkThemeColors.accentColor,
            backgroundColor: isLight
                ? LightThemeColors.backgroundColor
                : DarkThemeColors.backgroundColor,
            brightness: isLight ? Brightness.light : Brightness.dark,
          ).copyWith(
            secondary: isLight
                ? LightThemeColors.accentColor
                : DarkThemeColors.accentColor,
          ),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight
            ? LightThemeColors.cardColor
            : DarkThemeColors.cardColor,
        surfaceTintColor: isLight
            ? LightThemeColors.cardColor
            : DarkThemeColors.cardColor,
      ),

      // color contrast (if the theme is dark text should be white for example)
      brightness: isLight ? Brightness.light : Brightness.dark,

      // card widget background color
      cardColor: isLight
          ? LightThemeColors.cardColor
          : DarkThemeColors.cardColor,

      // hint text color
      hintColor: isLight
          ? LightThemeColors.hintTextColor
          : DarkThemeColors.hintTextColor,

      // divider color
      dividerColor: isLight
          ? LightThemeColors.dividerColor
          : DarkThemeColors.dividerColor,

      // app background color
      scaffoldBackgroundColor: isLight
          ? LightThemeColors.scaffoldBackgroundColor
          : DarkThemeColors.scaffoldBackgroundColor,

      // progress bar theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),
      dividerTheme: DividerThemeData(
        color: isLight
            ? LightThemeColors.primaryColor
            : DarkThemeColors.primaryColor,
      ),

      // elevated button theme
      elevatedButtonTheme: MyStyles.getElevatedButtonTheme(
        isLightTheme: isLight,
      ),

      // text theme
      textTheme: MyStyles.getTextTheme(isLightTheme: isLight),

      // icon theme
      iconTheme: MyStyles.getIconTheme(isLightTheme: isLight),

      // list tile theme
      listTileTheme: MyStyles.getListTileThemeData(isLightTheme: isLight),

      // custom themes
      extensions: [
        MyStyles.pupauTheme(isLight),
        MyStyles.getSkeletonThemeData(isLightTheme: isLight),
      ],
    );
  }

  static OutlineInputBorder defaultInputBorder(bool isLight) =>
      OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(
          color: isLight
              ? LightThemeColors.primaryColor
              : DarkThemeColors.primaryColor,
          width: 1,
        ),
      );

  /// update app theme and save theme type to shared pref
  /// (so when the app is killed and up again theme will remain the same)
  static void changeTheme(String theme) => Get.changeThemeMode(
    theme == "light"
        ? ThemeMode.light
        : theme == "dark"
        ? ThemeMode.dark
        : ThemeMode.system,
  );
}
