import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_info_box.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_switch.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/thinking_modal.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/active_skills_modal.dart';

class ChatToolsFAB extends GetView<PupauChatController> {
  const ChatToolsFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hideInputBox.value) return const SizedBox();
      if (controller.isVoiceMode.value) return const SizedBox();
      if (!controller.toolsFabExpanded.value) return const SizedBox();

      final bool isAnonymous = controller.isAnonymous;
      final PupauAttachmentsController attachmentsController =
          Get.find<PupauAttachmentsController>();
      final bool isEnabled = !controller.hasApiError.value;
      final bool isAttachmentAvailable = controller.isAttachmentAvailable();
      final bool isWebSearchAvailable = controller.isWebSearchAvailable();
      final bool isCustomActionsAvailable =
          controller.assistant.value?.customActions.isNotEmpty ?? false;
      final bool isThinkingAvailable = controller.isThinkingSupported();
      final int attachmentNumberEnabled = attachmentsController.attachments
          .where((element) => element.selected)
          .length;
      final bool isSendingAttachment =
          attachmentsController.sendingAttachments.value > 0;
      return SizedBox(
        height: DeviceService.height,
        width: DeviceService.width,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 54,
              left: 0,
              child: AbsorbPointer(
                absorbing: !isEnabled,
                child: Opacity(
                  opacity: isEnabled ? 1 : 0.5,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 80),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: isAnonymous
                          ? AnonymousThemeColors.userBubble
                          : MyStyles.pupauTheme(!Get.isDarkMode).white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 6),
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
                            fabInfo: attachmentNumberEnabled != 0
                                ? attachmentNumberEnabled.toString()
                                : null,
                            fabInfoLoading: isSendingAttachment,
                          ),
                        if (controller.conversationActiveSkills.isNotEmpty)
                          ChatToolMiniFab(
                            onTap: () => showActiveSkillsModal(),
                            label: Strings.activeSkills.tr,
                            tooltip: Strings.activeSkills.tr,
                            materialIcon: Constants.skillIcon,
                            fabInfo: controller.conversationActiveSkills.length
                                .toString(),
                          ),
                        if (isWebSearchAvailable)
                          ChatToolMiniFab(
                            onTap: () => controller.toggleWebSearch(),
                            label: Strings.webSearch.tr,
                            closesMenuOnTap: false,
                            onLongPress: () => showInfoBox(
                              Strings.webSearch.tr,
                              Strings.webSearchInfoShort.tr,
                            ),
                            iconPath:
                                '${Constants.assetPath}/images/web_search_tool.svg',
                            trailing: Transform.scale(
                              scale: 0.5,
                              child: CustomSwitch(
                                isActive: controller.isWebSearchActive(),
                                onChanged: (_) => controller.toggleWebSearch(),
                              ),
                            ),
                          ),
                        if (isCustomActionsAvailable)
                          ChatToolMiniFab(
                            onTap: () => controller.openCustomActionsModal(),
                            label: Strings.customActions.tr,
                            tooltip: Strings.customActions.tr,
                            iconPath:
                                '${Constants.assetPath}/images/custom_actions_tool.svg',
                          ),
                        if (isThinkingAvailable)
                          ChatToolMiniFab(
                            onTap: () => showThinkingModal(),
                            label: "Thinking Effort",
                            tooltip: "Thinking Effort",
                            materialIcon: Symbols.psychology,
                          ),
                      ],
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

class ChatToolMiniFab extends GetView<PupauChatController> {
  const ChatToolMiniFab({
    super.key,
    this.iconPath,
    this.materialIcon,
    required this.onTap,
    required this.label,
    this.tooltip,
    this.onLongPress,
    this.fabInfo,
    this.fabInfoLoading = false,
    this.trailing,
    this.closesMenuOnTap = true,
  });

  final String? iconPath;
  final IconData? materialIcon;
  final String label;
  final Function() onTap;
  final String? tooltip;
  final Function()? onLongPress;
  final String? fabInfo;
  final bool fabInfoLoading;
  final Widget? trailing;
  final bool closesMenuOnTap;

  @override
  Widget build(BuildContext context) {
    // [trailing] (the web-search switch) is kept OUTSIDE the InkWell below on
    // purpose: nesting it inside would make tapping the switch also trigger
    // the row's onTap depending on how the gesture arena resolves the tap —
    // unreliable. As a plain sibling, tapping it can never hit the InkWell.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: () {
              if (closesMenuOnTap) controller.toggleToolsFab(value: false);
              onTap();
            },
            borderRadius: BorderRadius.circular(8),
            onLongPress: onLongPress,
            child: Tooltip(
              message: tooltip ?? "",
              triggerMode: tooltip == null ? TooltipTriggerMode.manual : null,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  top: 12,
                  bottom: 12,
                  right: trailing != null ? 8 : 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ToolIcon(
                      iconPath: iconPath,
                      materialIcon: materialIcon,
                      fabInfo: fabInfo,
                      fabInfoLoading: fabInfoLoading,
                      onTap: onTap,
                    ),
                    const SizedBox(width: 8),
                    ToolLabel(label: label),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (trailing != null)
          Padding(padding: const EdgeInsets.only(right: 12), child: trailing!),
      ],
    );
  }
}

class ToolIcon extends GetView<PupauChatController> {
  const ToolIcon({
    super.key,
    this.iconPath,
    this.materialIcon,
    required this.fabInfo,
    required this.fabInfoLoading,
    required this.onTap,
  });

  final String? iconPath;
  final IconData? materialIcon;
  final String? fabInfo;
  final bool fabInfoLoading;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = controller.isAnonymous;
    final Color basicColor = isAnonymous
        ? Colors.black
        : (MyStyles.getTextTheme(
            isLightTheme: !Get.isDarkMode,
          ).bodyMedium?.color)!;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          height: 28,
          width: 28,
          child: Center(
            child: materialIcon != null
                ? Icon(materialIcon, color: basicColor)
                : iconPath != null
                ? SvgPicture.asset(
                    iconPath!,
                    colorFilter: ColorFilter.mode(basicColor, BlendMode.srcIn),
                  )
                : const SizedBox(),
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
                        ).primary.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: !fabInfoLoading
                    ? Center(
                        child: Text(
                          fabInfo ?? "",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
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

class ToolLabel extends GetView<PupauChatController> {
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
        color: isAnonymous
            ? Colors.black
            : MyStyles.getTextTheme(
                isLightTheme: !Get.isDarkMode,
              ).bodyMedium?.color,
      ),
    );
  }
}
