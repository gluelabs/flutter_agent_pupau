import 'package:flutter/material.dart';

class PupauThemeData extends ThemeExtension<PupauThemeData> {
  final Color primary;
  final Color white;
  final Color black;
  final Color grey;
  final Color yellowWarning;
  final Color redAlarm;
  final Color green;
  final Color codeBackground;
  final Color assistantCardBackground;
  final Color betaPreviewChipBackground;

  const PupauThemeData({
    required this.primary,
    required this.white,
    required this.black,
    required this.grey,
    required this.yellowWarning,
    required this.redAlarm,
    required this.green,
    required this.codeBackground,
    required this.assistantCardBackground,
    required this.betaPreviewChipBackground,
  });

  @override
  ThemeExtension<PupauThemeData> copyWith() {
    return PupauThemeData(
      primary: primary,
      white: white,
      black: black,
      grey: grey,
      yellowWarning: yellowWarning,
      redAlarm: redAlarm,
      green: green,
      codeBackground: codeBackground,
      assistantCardBackground: assistantCardBackground,
      betaPreviewChipBackground: betaPreviewChipBackground,
    );
  }

  @override
  ThemeExtension<PupauThemeData> lerp(
    covariant ThemeExtension<PupauThemeData>? other,
    double t,
  ) {
    if (other is! PupauThemeData) {
      return this;
    }

    return PupauThemeData(
      primary: primary,
      white: white,
      black: black,
      grey: grey,
      yellowWarning: yellowWarning,
      redAlarm: redAlarm,
      green: green,
      codeBackground: codeBackground,
      assistantCardBackground: assistantCardBackground,
      betaPreviewChipBackground: betaPreviewChipBackground,
    );
  }
}
