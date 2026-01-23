import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class LoadingToolUse extends GetView<ChatController> {
  const LoadingToolUse({
    super.key,
    required this.toolName,
    required this.toolUseType,
  });

  final String toolName;
  final ToolUseType toolUseType;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    IconData? toolUseIcon = ToolUseService.getToolUseIcon(toolUseType);
    return Container(
      padding: EdgeInsets.only(top: 4),
      margin: EdgeInsets.symmetric(horizontal: 10),
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
              child: Column(
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
                                        : MyStyles.pupauTheme(
                                            !Get.isDarkMode,
                                          ).accent,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 8,
                                ),
                                child: SizedBox(
                                  width: 9,
                                  height: 9,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Get.isDarkMode || isAnonymous
                                        ? Colors.white
                                        : MyStyles.pupauTheme(
                                            !Get.isDarkMode,
                                          ).accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
