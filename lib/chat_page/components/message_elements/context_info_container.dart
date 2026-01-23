import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/context_info_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ContextInfoContainer extends GetView<ChatController> {
  const ContextInfoContainer({
    super.key,
    required this.contextInfo,
  });

  final ContextInfo? contextInfo;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      bool showNerdStats = controller.showNerdStats.value;
      bool isAnonymous = controller.isAnonymous;
      return showNerdStats
          ? Padding(
              padding: const EdgeInsets.only(bottom: 4, top: 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: isTablet ? null : DeviceService.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: isAnonymous
                          ? AnonymousThemeColors.background
                          : MyStyles.pupauTheme(!Get.isDarkMode)
                              .grey
                              .withValues(alpha: Get.isDarkMode ? 1 : 0.1)),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 4,
                    children: [
                      Icon(Symbols.bar_chart,
                          size: isTablet ? 26 : 24,
                          color: isAnonymous
                              ? AnonymousThemeColors.assistantText
                              : null),
                      ContextInfoItem(
                          label: Strings.context.tr,
                          info:
                              "${contextInfo?.usedContext}/${contextInfo?.availableContext}",
                          isAnonymous: isAnonymous),
                      ContextInfoItem(
                          label: Strings.userQueryTokens.tr,
                          info: contextInfo?.userQuery.toString() ?? "",
                          isAnonymous: isAnonymous),
                      ContextInfoItem(
                          label: Strings.outputTokens.tr,
                          info: contextInfo?.outputTokens.toString() ?? "",
                          isAnonymous: isAnonymous),
                      ContextInfoItem(
                          label: Strings.credits.tr,
                          info: StringService.removeTrailingZeros(
                              contextInfo?.credit.toString() ?? ""),
                          isAnonymous: isAnonymous)
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox();
    });
  }
}
