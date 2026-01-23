import 'package:flutter/material.dart';

// todo configure text family and size
class MyFonts {
  // return the right font depending on app language
  static TextStyle get getAppFontType => const TextStyle(fontFamily: 'Poppins');

  // headlines text font
  static TextStyle get displayTextStyle => getAppFontType;

  // body text font
  static TextStyle get bodyTextStyle => getAppFontType;

  // button text font
  static TextStyle get buttonTextStyle => getAppFontType;

  // app bar text font
  static TextStyle get appBarTextStyle => getAppFontType;

  // chips text font
  static TextStyle get chipTextStyle => getAppFontType;

  // appbar font size
  static double get appBarTittleSize => 18;

  // body font size
  static double get bodySmallTextSize => 11;
  static double get bodyMediumSize => 14; // default font
  static double get bodyLargeSize => 16;
  // display font size
  static double get displayLargeSize => 20;
  static double get displayMediumSize => 17;
  static double get displaySmallSize => 14;

  //button font size
  static double get buttonTextSize => 16;

  //chip font size
  static double get chipTextSize => 10;

  // list tile fonts sizes
  static double get listTileTitleSize => 13;
  static double get listTileSubtitleSize => 12;
}
