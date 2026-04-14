import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tool_preview_content.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

class LoadingToolUse extends GetView<PupauChatController> {
  const LoadingToolUse({
    super.key,
    required this.toolName,
    required this.toolKey,
    required this.toolUseType,
  });

  final String toolName;
  final String toolKey;
  final ToolUseType toolUseType;

  static String _loadingLabelForTool(String name) {
    final String t = name.trim().toLowerCase();
    // Native Database (native_db_*)
    switch (t) {
      case 'native_db_list':
        return Strings.nativeDbLoadingList.tr;
      case 'native_db_search':
        return Strings.nativeDbLoadingSearch.tr;
      case 'native_db_insert':
        return Strings.nativeDbLoadingInsert.tr;
      case 'native_db_update':
        return Strings.nativeDbLoadingUpdate.tr;
      case 'native_db_delete':
        return Strings.nativeDbLoadingDelete.tr;
      case 'native_db_create_database':
        return Strings.nativeDbLoadingCreateDatabase.tr;
      case 'native_db_add_column':
        return Strings.nativeDbLoadingAddColumn.tr;
    }

    // Spreadsheet (spreadsheet_*) — same infra, but user-facing copy differs.
    switch (t) {
      case 'spreadsheet_info':
        return Strings.spreadsheetLoadingInfo.tr;
      case 'spreadsheet_sample':
        return Strings.spreadsheetLoadingSample.tr;
      case 'spreadsheet_search':
        return Strings.spreadsheetLoadingSearch.tr;
      case 'spreadsheet_insert':
        return Strings.spreadsheetLoadingInsert.tr;
      case 'spreadsheet_update':
        return Strings.spreadsheetLoadingUpdate.tr;
      case 'spreadsheet_delete':
        return Strings.spreadsheetLoadingDelete.tr;
      case 'spreadsheet_summary':
        return Strings.spreadsheetLoadingSummary.tr;
      case 'spreadsheet_distinct':
        return Strings.spreadsheetLoadingDistinct.tr;
    }

    // Fallback: show nothing (keeps UI compact).
    return '';
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    IconData? toolUseIcon = ToolUseService.getToolUseIcon(toolUseType);
    final bool canShowPreview = controller.hasToolArgsPreview(toolKey);
    final String loadingLabel = _loadingLabelForTool(toolKey);
    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: StyleService.getBubbleColor(true, isAnonymous, false),
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              focusColor: Colors.transparent,
            ),
            child: InkWell(
              onTap: () => controller.toggleLoadingToolExpanded(toolKey),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isAnonymous
                        ? Colors.white70
                        : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed,
                  ),
                ),
                child: Obx(() {
                  final bool isExpanded =
                      controller.isLoadingToolExpanded(
                        toolKey,
                        toolUseType: toolUseType,
                      );
                  final bool isUserToggled = controller.userToggledLoadingTools
                      .contains(toolKey.trim());
                  final String elapsedLabel =
                      '${controller.getToolLoadingSeconds(toolKey)}s';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ToolUseAvatar(
                            toolUseIcon: toolUseIcon,
                            isAnonymous: isAnonymous,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      toolName.replaceAll("_", " ").capitalize ??
                                          toolName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 16 : 14,
                                        color: Get.isDarkMode || isAnonymous
                                            ? Colors.white
                                            : MyStyles.pupauTheme(!Get.isDarkMode)
                                                .accent,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 12),
                                    child: SizedBox(
                                      width: 9,
                                      height: 9,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Get.isDarkMode || isAnonymous
                                            ? Colors.white
                                            : MyStyles.pupauTheme(!Get.isDarkMode)
                                                .accent,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Text(
                                      elapsedLabel,
                                      style: TextStyle(
                                        fontSize: isTablet ? 15 : 13,
                                        fontWeight: FontWeight.w600,
                                        color: Get.isDarkMode || isAnonymous
                                            ? Colors.white.withValues(alpha: 0.7)
                                            : MyStyles.pupauTheme(!Get.isDarkMode)
                                                .accent
                                                .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: AnimatedRotation(
                              turns: isExpanded ? 0.75 : 0.25,
                              duration: isUserToggled
                                  ? const Duration(milliseconds: 200)
                                  : Duration.zero,
                              curve: Curves.easeInOut,
                              child: Icon(
                                Symbols.chevron_forward,
                                color: Get.isDarkMode || isAnonymous
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : MyStyles.pupauTheme(!Get.isDarkMode)
                                        .accent
                                        .withValues(alpha: 0.7),
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (loadingLabel.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 36, top: 2),
                          child: Text(
                            loadingLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: StyleService.toolNormalTextStyle(
                              Get.isDarkMode || isAnonymous,
                            ),
                          ),
                        ),
                      if (isExpanded && canShowPreview)
                        LoadingToolPreviewContent(toolName: toolKey),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
