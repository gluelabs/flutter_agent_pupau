import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/loading_tool_preview_content.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
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

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    IconData? toolUseIcon = ToolUseService.getToolUseIcon(toolUseType);
    final bool canShowPreview = controller.hasToolArgsPreview(toolKey);
    return Container(
      padding: const EdgeInsets.only(top: 4),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Material(
        color: StyleService.getBubbleColor(true, isAnonymous, false),
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => controller.toggleLoadingToolExpanded(toolKey),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Theme(
              data: Theme.of(context).copyWith(
                splashFactory: NoSplash.splashFactory,
                focusColor: Colors.transparent,
              ),
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
                  final int elapsedSeconds =
                      controller.getToolLoadingSeconds(toolKey);
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
                                      '${elapsedSeconds}s',
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
