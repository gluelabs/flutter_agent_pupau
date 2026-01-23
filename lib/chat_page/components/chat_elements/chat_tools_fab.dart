import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_info_box.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ChatToolsFAB extends GetView<ChatController> {
  const ChatToolsFAB({super.key});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    bool isTablet = DeviceService.isTablet;
    AttachmentsController attachmentsController =
        Get.find<AttachmentsController>();
    bool hideInputBox = controller.hideInputBox;
    if(hideInputBox) return const SizedBox();
    return Obx(() {
      bool isEnabled = !controller.hasApiError.value;
      bool isExpanded = controller.toolsFabExpanded.value;
      bool isAttachmentAvailable = controller.isAttachmentAvailable();
      bool isWebSearchAvailable = controller.isWebSearchAvailable();
      bool isCustomActionsAvailable =
          controller.assistant.value?.customActions.isNotEmpty ?? false;
      int attachmentNumberEnabled = attachmentsController.attachments
          .where((element) => element.active)
          .length;
      bool isSendingAttachment =
          attachmentsController.sendingAttachments.value > 0;
      bool isDarkMode = Get.isDarkMode;
      bool isFocused = controller.isMessageInputFieldFocused.value;
      return SizedBox(
        height: DeviceService.height,
        width: DeviceService.width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (isExpanded) ...[
              Positioned(
                bottom: 48,
                left: 0,
                child: AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1 : 0.5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isAttachmentAvailable)
                          ChatToolMiniFab(
                            onTap: () =>
                                attachmentsController.openAttachmentsModal(),
                            label: Strings.attachments.tr,
                            tooltip: Strings.attachments.tr,
                            iconPath:
                                '${Constants.assetPath}/images/attachments_tool.svg',
                            color: isAnonymous
                                ? Colors.black
                                : isDarkMode
                                ? MyStyles.pupauTheme(false).darkBlue
                                : null,
                            fabInfo: attachmentNumberEnabled != 0
                                ? attachmentNumberEnabled.toString()
                                : null,
                            fabInfoLoading: isSendingAttachment,
                          ),
                        if (isWebSearchAvailable)
                          ChatToolMiniFab(
                            onTap: () => controller.toggleWebSearch(),
                            label: Strings.webSearch.tr,
                            isEnabled: controller.isWebSearchActive(),
                            onLongPress: () => showInfoBox(
                              Strings.webSearch.tr,
                              Strings.webSearchInfoShort.tr,
                            ),
                            color: isAnonymous
                                ? Colors.black
                                : isDarkMode
                                ? MyStyles.pupauTheme(false).green
                                : null,
                            iconPath:
                                '${Constants.assetPath}/images/web_search_tool.svg',
                          ),
                        if (isCustomActionsAvailable)
                          ChatToolMiniFab(
                            onTap: () => controller.openCustomActionsModal(),
                            label: Strings.customActions.tr,
                            tooltip: Strings.customActions.tr,
                            iconPath:
                                '${Constants.assetPath}/images/custom_actions_tool.svg',
                            color: isAnonymous
                                ? Colors.black
                                : isDarkMode
                                ? MyStyles.pupauTheme(true).magenta
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            Align(
              alignment: Alignment.bottomLeft,
              child: AbsorbPointer(
                absorbing: !isEnabled,
                child: Opacity(
                  opacity: isEnabled ? 1 : 0.5,
                  child: Material(
                    color: isAnonymous
                        ? AnonymousThemeColors.userBubble
                        : MyStyles.pupauTheme(!Get.isDarkMode).lilac,
                    borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => controller.toggleToolsFab(),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(8),
                      ),
                      child: Container(
                        height: 50,
                        width: 48,
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: isAnonymous
                                  ? Colors.transparent
                                  : isFocused
                                  ? MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacPressed
                                  : MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacHover,
                            ),
                            top: BorderSide(
                              color: isAnonymous
                                  ? Colors.transparent
                                  : isFocused
                                  ? MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacPressed
                                  : MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacHover,
                            ),
                            bottom: BorderSide(
                              color: isAnonymous
                                  ? Colors.transparent
                                  : isFocused
                                  ? MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacPressed
                                  : MyStyles.pupauTheme(
                                      !Get.isDarkMode,
                                    ).lilacHover,
                            ),
                          ),
                          borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(8),
                          ),
                        ),
                        child: Icon(
                          isExpanded ? Symbols.remove : Symbols.add,
                          size: isTablet ? 26 : 24,
                          color: isAnonymous
                              ? Colors.black
                              : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class ChatToolMiniFab extends GetView<ChatController> {
  const ChatToolMiniFab({
    super.key,
    required this.iconPath,
    required this.onTap,
    required this.label,
    this.tooltip,
    this.onLongPress,
    this.color,
    this.isEnabled = true,
    this.fabInfo,
    this.fabInfoLoading = false,
  });

  final String iconPath;
  final String label;
  final Function() onTap;
  final String? tooltip;
  final Color? color;
  final Function()? onLongPress;
  final bool isEnabled;
  final String? fabInfo;
  final bool fabInfoLoading;

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        borderRadius: BorderRadius.circular(24),
        color: isAnonymous
            ? AnonymousThemeColors.userBubble
            : MyStyles.pupauTheme(!Get.isDarkMode).lilac,
        elevation: 0,
        child: InkWell(
          onTap: () {
            controller.toggleToolsFab(value: false);
            onTap();
          },
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(24),
          child: Tooltip(
            message: tooltip ?? "",
            triggerMode: tooltip == null ? TooltipTriggerMode.manual : null,
            child: Container(
              padding: const EdgeInsets.only(
                top: 2,
                bottom: 2,
                left: 4,
                right: 10,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  ToolIcon(
                    isEnabled: isEnabled,
                    iconPath: iconPath,
                    color: color,
                    fabInfo: fabInfo,
                    fabInfoLoading: fabInfoLoading,
                    onTap: onTap,
                  ),
                  ToolLabel(label: label),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ToolIcon extends GetView<ChatController> {
  const ToolIcon({
    super.key,
    required this.isEnabled,
    required this.iconPath,
    required this.color,
    required this.fabInfo,
    required this.fabInfoLoading,
    required this.onTap,
  });

  final bool isEnabled;
  final String iconPath;
  final Color? color;
  final String? fabInfo;
  final bool fabInfoLoading;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 36,
          width: 36,
          child: Center(
            child: Opacity(
              opacity: isEnabled ? 1 : 0.5,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: color != null
                    ? ColorFilter.mode(color!, BlendMode.srcIn)
                    : null,
              ),
            ),
          ),
        ),
        if (fabInfo != null || fabInfoLoading)
          Positioned(
            top: -1,
            right: -1,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? Colors.black
                      : MyStyles.pupauTheme(
                          !Get.isDarkMode,
                        ).blue.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: !fabInfoLoading
                    ? Center(
                        child: Text(
                          fabInfo ?? "",
                          style: TextStyle(
                            fontSize: 12,
                            color: isAnonymous
                                ? Colors.white
                                : MyStyles.pupauTheme(!Get.isDarkMode).white,
                          ),
                        ),
                      )
                    : const Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 9,
                          height: 9,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class ToolLabel extends GetView<ChatController> {
  const ToolLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    bool isTablet = DeviceService.isTablet;
    return Text(
      label,
      style: TextStyle(
        fontSize: isTablet ? 14 : 12,
        fontWeight: FontWeight.w500,
        color: isAnonymous ? Colors.black : null,
      ),
    );
  }
}
