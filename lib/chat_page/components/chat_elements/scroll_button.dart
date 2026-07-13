import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ScrollButton extends StatelessWidget {
  const ScrollButton({
    super.key,
    required this.toBottom,
    required this.isVisible,
    required this.onTap,
    this.icon,
    this.svgAssetPath,
    this.tooltip,
    this.isAnonymous = false,
    this.keepSvgColor = false,
  });

  final bool toBottom;
  final bool isVisible;
  final Function() onTap;
  final IconData? icon;
  final String? svgAssetPath;
  final String? tooltip;
  final bool isAnonymous;
  final bool keepSvgColor;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    // Content is primary so it stays visible now that the button's fill
    // matches the chat background instead of being a solid accent circle.
    final Color iconColor = isAnonymous
        ? AnonymousThemeColors.primary
        : MyStyles.pupauTheme(!Get.isDarkMode).primary;
    final Color backgroundColor = isAnonymous
        ? AnonymousThemeColors.background
        : MyStyles.pupauTheme(!Get.isDarkMode).white;

    return Visibility(
      visible: isVisible,
      child: Align(
        alignment: toBottom ? Alignment.bottomRight : Alignment.topRight,
        child: Tooltip(
          preferBelow: !toBottom,
          message:
              tooltip ??
              (toBottom ? Strings.scrollToBottom.tr : Strings.scrollToTop.tr),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Material(
              // Same fill as the chat background — elevation is what makes it
              // stand out (a drop shadow) rather than a contrasting color.
              color: backgroundColor,
              shape: const CircleBorder(),
              elevation: 3,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: isTablet ? 48 : 42,
                  height: isTablet ? 48 : 42,
                  child: Center(
                    child:
                        svgAssetPath != null && svgAssetPath!.trim().isNotEmpty
                        ? _FauxBoldSvg(
                            assetPath: svgAssetPath!,
                            width: isTablet ? 28 : 24,
                            height: isTablet ? 28 : 24,
                            colorFilter: keepSvgColor
                                ? null
                                : ColorFilter.mode(iconColor, BlendMode.srcIn),
                          )
                        : Icon(
                            icon ??
                                (toBottom
                                    ? Symbols.arrow_downward
                                    : Symbols.arrow_upward),
                            size: isTablet ? 32 : 26,
                            color: iconColor,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// SVG assets have no font-weight axis (unlike the Material Symbols variable
/// font used everywhere else, which defaults to `weight: 600` app-wide via
/// [MyStyles.getIconTheme]). Layering a few sub-pixel-offset copies thickens
/// the silhouette to roughly match that same visual weight.
class _FauxBoldSvg extends StatelessWidget {
  const _FauxBoldSvg({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.colorFilter,
  });

  final String assetPath;
  final double width;
  final double height;
  final ColorFilter? colorFilter;

  static const List<Offset> _offsets = [
    Offset(-0.4, 0),
    Offset(0.4, 0),
    Offset(0, -0.4),
    Offset(0, 0.4),
  ];

  @override
  Widget build(BuildContext context) {
    Widget svg() => SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      colorFilter: colorFilter,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        for (final offset in _offsets)
          Transform.translate(offset: offset, child: svg()),
        svg(),
      ],
    );
  }
}
