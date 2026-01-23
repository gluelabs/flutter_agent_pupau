import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';

class ToolUseInfo extends StatelessWidget {
  const ToolUseInfo({
    super.key,
    required this.infoKey,
    required this.infoValue,
    required this.isAnonymous,
    this.forceExpanded = false,
  });

  final String infoKey;
  final String infoValue;
  final bool isAnonymous;
  final bool forceExpanded;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    RxBool isExpanded = forceExpanded ? true.obs : false.obs;
    return ExpandedTile(
      theme: const ExpandedTileThemeData(
        headerColor: Colors.transparent,
        contentBackgroundColor: Colors.transparent,
        headerPadding: EdgeInsets.symmetric(horizontal: 0),
        contentPadding: EdgeInsets.symmetric(horizontal: 0),
        titlePadding: EdgeInsets.zero,
        trailingPadding: EdgeInsets.only(left: 10, right: 5),
        footerPadding: EdgeInsets.zero,
        leadingPadding: EdgeInsets.zero,
        headerBorder: null,
        contentBorder: null,
        contentSeparatorColor: Colors.transparent,
      ),
      controller: ExpandedTileController(isExpanded: forceExpanded),
      enabled: !forceExpanded,
      title: Row(
        children: [
          Expanded(
            child: Text(
              infoKey,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: isAnonymous
                    ? AnonymousThemeColors.assistantText
                    : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                        .bodyMedium
                        ?.color,
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(15, 0),
            child: IconButton(
              icon: Icon(Symbols.content_copy, size: isTablet ? 26 : 22),
              tooltip: Strings.copy.tr,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: infoValue));
                showFeedbackSnackbar(
                    Strings.copiedClipboard.tr, Symbols.content_copy,
                    isInfo: true);
              },
            ),
          ),
        ],
      ),
      onTap: () => forceExpanded ? null : isExpanded.value = !isExpanded.value,
      trailing: Transform.translate(
        offset: const Offset(4, 12.5),
        child: Obx(() => Visibility(
              visible: !forceExpanded,
              child: AnimatedRotation(
                  duration: const Duration(milliseconds: 100),
                  turns: isExpanded.value ? 0.5 : 1,
                  child: Icon(Symbols.expand_more, size: isTablet ? 26 : 22)),
            )),
      ),
      trailingRotation: 0,
      content: Align(
        alignment: Alignment.centerLeft,
        child: Transform.translate(
          offset: Offset(0, forceExpanded ? -10 : 0),
          child: Text(
            infoValue,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: isAnonymous
                  ? AnonymousThemeColors.assistantText
                  : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                      .bodyMedium
                      ?.color,
            ),
          ),
        ),
      ),
    );
  }
}
