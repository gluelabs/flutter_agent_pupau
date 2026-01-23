import 'package:flutter/material.dart';

class PupauThemeData extends ThemeExtension<PupauThemeData> {
  final Color accent;
  final Color blue;
  final Color darkBlue;
  final Color white;
  final Color black;
  final Color grey;
  final Color magenta;
  final Color lilac;
  final Color lilacHover;
  final Color lilacPressed;
  final Color blueInfo;
  final Color yellowWarning;
  final Color redAlarm;
  final Color green;
  final Color codeBackground;
  final Color betaPreviewChipBackground;

  const PupauThemeData({
    required this.accent,
    required this.blue,
    required this.darkBlue,
    required this.white,
    required this.black,
    required this.grey,
    required this.magenta,
    required this.lilac,
    required this.lilacHover,
    required this.lilacPressed,
    required this.blueInfo,
    required this.yellowWarning,
    required this.redAlarm,
    required this.green,
    required this.codeBackground,
    required this.betaPreviewChipBackground,
  });

  @override
  ThemeExtension<PupauThemeData> copyWith() {
    return PupauThemeData(
      accent: accent,
      blue: blue,
      darkBlue: darkBlue,
      white: white,
      black: black,
      grey: grey,
      magenta: magenta,
      lilac: lilac,
      lilacHover: lilacHover,
      lilacPressed: lilacPressed,
      blueInfo: blueInfo,
      yellowWarning: yellowWarning,
      redAlarm: redAlarm,
      green: green,
      codeBackground: codeBackground,
      betaPreviewChipBackground: betaPreviewChipBackground,
    );
  }

  @override
  ThemeExtension<PupauThemeData> lerp(
      covariant ThemeExtension<PupauThemeData>? other, double t) {
    if (other is! PupauThemeData) {
      return this;
    }

    return PupauThemeData(
      accent: accent,
      blue: blue,
      darkBlue: darkBlue,
      white: white,
      black: black,
      grey: grey,
      magenta: magenta,
      lilac: lilac,
      lilacHover: lilacHover,
      lilacPressed: lilacPressed,
      blueInfo: blueInfo,
      yellowWarning: yellowWarning,
      redAlarm: redAlarm,
      green: green,
      codeBackground: codeBackground,
      betaPreviewChipBackground: betaPreviewChipBackground,
    );
  }
}
