import 'package:flutter/material.dart';

class SkeletonThemeData extends ThemeExtension<SkeletonThemeData> {
  final Color mainColor;
  final Color shimmerColor;

  const SkeletonThemeData({
    required this.mainColor,
    required this.shimmerColor,
  });

  @override
  ThemeExtension<SkeletonThemeData> copyWith() {
    return SkeletonThemeData(
      mainColor: mainColor,
      shimmerColor: shimmerColor,
    );
  }

  @override
  ThemeExtension<SkeletonThemeData> lerp(
      covariant ThemeExtension<SkeletonThemeData>? other, double t) {
    if (other is! SkeletonThemeData) {
      return this;
    }

    return SkeletonThemeData(mainColor: mainColor, shimmerColor: shimmerColor);
  }
}
