import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

/// Top bar title for [WoltModalSheetPage] in the same format as [users_group_modal].
/// Supports static title, [Obx] title via [titleWidget], custom leading/trailing,
/// and isTablet-based trailing (e.g. show close only on tablet).
class ModalTopBarTitle extends StatelessWidget {
  const ModalTopBarTitle({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.leadingWidth = 48,
    this.trailing,
    this.showCloseIcon = true,
    this.style,
    this.textAlign = TextAlign.center,
  }) : assert(
          title != null || titleWidget != null,
          'Either title or titleWidget must be provided',
        );

  /// Static title string. Ignored if [titleWidget] is set.
  final String? title;

  /// Custom title widget (e.g. Obx(() => Text(...)) for reactive title).
  /// Placed inside [Expanded] with padding; no ellipsis applied.
  final Widget? titleWidget;

  /// Leading widget. When null, uses [SizedBox(width: leadingWidth)].
  final Widget? leading;

  /// Width used for default leading and for trailing spacer when no close icon.
  final double leadingWidth;

  /// Custom trailing widget. When null, uses [CloseIcon] if [showCloseIcon]
  /// else [SizedBox(width: leadingWidth)] (e.g. for phone when close is only on tablet).
  final Widget? trailing;

  /// When true and [trailing] is null, shows [CloseIcon]. When false and [trailing]
  /// is null, shows [SizedBox(width: leadingWidth)].
  final bool showCloseIcon;

  /// Text style for [title]. Ignored when [titleWidget] is used.
  final TextStyle? style;

  /// Text align for [title]. Ignored when [titleWidget] is used.
  final TextAlign textAlign;

  static TextStyle _defaultStyle() {
    final bool isTablet = DeviceService.isTablet;
    return TextStyle(
      fontSize: isTablet ? 18 : 16,
      fontWeight: FontWeight.w600,
      color: MyStyles.pupauTheme(!Get.isDarkMode).primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leading ?? SizedBox(width: leadingWidth),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: titleWidget != null
                ? titleWidget!
                : Text(
                    title!,
                    textAlign: textAlign,
                    style: style ?? _defaultStyle(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
          ),
        ),
        if (trailing != null)
          trailing!
        else if (showCloseIcon)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: CloseIcon(),
          )
        else
          SizedBox(width: leadingWidth),
      ],
    );
  }
}
