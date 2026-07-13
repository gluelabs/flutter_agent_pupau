import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_image_generation_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/basic_tool_use_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/image_generation_tool_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/smtp_info_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_message_content.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/web_search_tool_modals.dart';

class ToolUseBubble extends GetView<PupauChatController> {
  const ToolUseBubble({
    super.key,
    required this.message,
    this.disableCollapseAndToggle = false,
    this.showContentOnly = false,
    this.hideBorder = false,
  });

  final ToolUseMessage message;
  final bool disableCollapseAndToggle;
  final bool showContentOnly;
  final bool hideBorder;

  void tapToolUse() {
    if (disableCollapseAndToggle) return;
    if (message.type == ToolUseType.nativeToolsWebSearch) {
      openWebSearchToolModals(message);
    } else if (message.type == ToolUseType.nativeToolsSMTP) {
      showSMTPInfoModal(message);
    } else if (ToolUseService.isModalToolUse(message.type)) {
      showBasicToolUseModal(message, controller.isAnonymous);
    } else if (message.type == ToolUseType.nativeToolsImageGeneration) {
      List<GeneratedImageData> images =
          message.imageGenerationData?.images ?? [];
      images.isNotEmpty
          ? showImageGenerationToolModal(images)
          : controller.toggleToolUseExpanded(message.id);
    } else if (message.type == ToolUseType.nativeToolsWebReader &&
        message.webReaderData?.url != null &&
        message.webReaderData?.url != "") {
      DeviceService.openLink(message.webReaderData?.url ?? "");
    } else {
      controller.toggleToolUseExpanded(message.id);
    }
  }

  static bool isMemoryNotificationTool(ToolUseMessage message) {
    if (message.type != ToolUseType.nativeToolsMemoryProfile) return false;
    final String toolName = message.toolName.trim().toLowerCase();
    if (toolName != 'memory_create' &&
        toolName != 'memory_update' &&
        toolName != 'memory_delete') {
      return false;
    }
    final String action =
        message.memoryProfileData?.action.trim().toUpperCase() ?? '';
    return action == 'CREATE' || action == 'UPDATE' || action == 'DELETE';
  }

  static String memoryNotificationTitle(ToolUseMessage message) {
    final String toolName = message.toolName.trim().toLowerCase();
    switch (toolName) {
      case 'memory_create':
        return Strings.memorySaved.tr;
      case 'memory_update':
        return Strings.memoryUpdated.tr;
      case 'memory_delete':
        return Strings.memoryRemoved.tr;
      default:
        return message.getName();
    }
  }

  static IconData memoryNotificationIcon(ToolUseMessage message) {
    final String toolName = message.toolName.trim().toLowerCase();
    switch (toolName) {
      case 'memory_create':
        return Symbols.bookmark_add;
      case 'memory_update':
        return Symbols.edit;
      case 'memory_delete':
        return Symbols.delete;
      default:
        return Symbols.psychology;
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    final bool isInitiallyExpanded = ToolUseService.isInitiallyExpandedTool(
      message.type,
    );
    final bool isAnonymous = controller.isAnonymous;
    final bool showTool = message.showTool;
    final bool isMemoryNotification = isMemoryNotificationTool(message);
    final bool effectiveDisableToggle =
        disableCollapseAndToggle || isMemoryNotification;
    final bool forceExpanded = showContentOnly || isMemoryNotification;
    return Visibility(
      visible: showTool,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: showContentOnly
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(vertical: 6),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              focusColor: Colors.transparent,
            ),
            child: InkWell(
              onTap: effectiveDisableToggle ? null : tapToolUse,
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: showContentOnly
                    ? EdgeInsets.zero
                    : const EdgeInsets.only(
                        left: 6,
                        right: 15,
                        top: 8,
                        bottom: 8,
                      ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Obx(() {
                  bool isExpanded = forceExpanded
                      ? true
                      : (isInitiallyExpanded
                            ? !controller.isToolUseExpanded(message.id)
                            : controller.isToolUseExpanded(message.id));
                  IconData? toolSuffixIcon =
                      ToolUseMessage.getToolUseSuffixIcon(message.type);
                  bool isChevronIcon =
                      toolSuffixIcon == Symbols.chevron_forward;
                  bool isUserToggled = controller.userToggledToolUseMessages
                      .contains(message.id);
                  IconData? toolUseIcon = isMemoryNotification
                      ? memoryNotificationIcon(message)
                      : ToolUseService.getToolUseIcon(message.type);
                  final String title = isMemoryNotification
                      ? memoryNotificationTitle(message)
                      : message.getName();
                  final Color basicColor = isAnonymous
                      ? AnonymousThemeColors.assistantText
                      : (MyStyles.getTextTheme(
                          isLightTheme: !Get.isDarkMode,
                        ).bodyMedium?.color)!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!showContentOnly)
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
                                    Flexible(
                                      child: Text(
                                        title,
                                        maxLines: isExpanded ? 10 : 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: hideBorder
                                            ? TextStyle(
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w600,
                                              )
                                            : TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: isTablet ? 16 : 14,
                                                color: basicColor,
                                              ),
                                      ),
                                    ),
                                    if (message
                                            .browserUseData
                                            ?.isLoadingPlaceholder ??
                                        false)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
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
                                                  ).primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (!forceExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: AnimatedRotation(
                                  key: ValueKey('${message.id}_rotation'),
                                  turns: isChevronIcon
                                      ? (isExpanded ? 0.75 : 0.25)
                                      : 0,
                                  duration: isUserToggled
                                      ? const Duration(milliseconds: 200)
                                      : Duration.zero,
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    ToolUseMessage.getToolUseSuffixIcon(
                                      message.type,
                                    ),
                                    color: basicColor.withValues(alpha: 0.7),
                                    size: 24,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      _ToolUseExpandableContent(
                        key: ValueKey<String>(
                          '${message.id}_${message.thinkingData?.thought ?? message.toolMessage}',
                        ),
                        messageId: message.id,
                        isExpanded: isExpanded,
                        isUserToggled: isUserToggled,
                        isAnonymous: isAnonymous,
                        message: message,
                        showContentOnly: showContentOnly,
                      ),
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

/// Uses [SizeTransition] driven by a manually controlled [AnimationController]
/// instead of [AnimatedSize]/[RenderAnimatedSize]. This avoids the
/// "RenderAnimatedSize mutated in its own performLayout" error that occurs
/// because [RenderAnimatedSize._layoutStable] calls [AnimationController.forward]
/// synchronously during the layout pass, triggering [markNeedsLayout] on itself.
class _ToolUseExpandableContent extends StatefulWidget {
  const _ToolUseExpandableContent({
    super.key,
    required this.messageId,
    required this.isExpanded,
    required this.isUserToggled,
    required this.isAnonymous,
    required this.message,
    required this.showContentOnly,
  });

  final String messageId;
  final bool isExpanded;
  final bool isUserToggled;
  final bool isAnonymous;
  final ToolUseMessage message;
  final bool showContentOnly;

  @override
  State<_ToolUseExpandableContent> createState() =>
      _ToolUseExpandableContentState();
}

class _ToolUseExpandableContentState extends State<_ToolUseExpandableContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: widget.isExpanded ? 1.0 : 0.0,
    );
    _sizeFactor = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant _ToolUseExpandableContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      final duration = widget.isUserToggled
          ? const Duration(milliseconds: 200)
          : Duration.zero;
      _controller.duration = duration;
      _controller.reverseDuration = duration;
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeFactor,
      alignment: Alignment.topCenter,
      child: Padding(
        padding: widget.showContentOnly
            ? EdgeInsets.zero
            : const EdgeInsets.only(top: 8),
        child: ToolUseMessageContent(
          toolUseMessage: widget.message,
          isAnonymous: widget.isAnonymous,
          showContentOnly: widget.showContentOnly,
        ),
      ),
    );
  }
}
