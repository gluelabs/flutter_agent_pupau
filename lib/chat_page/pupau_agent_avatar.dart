import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_skeleton.dart';
import 'package:flutter_agent_pupau/chat_page/pupau_agent_chat.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_bindings.dart';

class PupauAgentAvatar extends StatefulWidget {
  final PupauConfig? config;
  final double radius = 32;
  final ImageFormat format = ImageFormat.medium;

  const PupauAgentAvatar({super.key, this.config});

  @override
  State<PupauAgentAvatar> createState() => _PupauAgentAvatarState();
}

class _PupauAgentAvatarState extends State<PupauAgentAvatar> {
  bool _isExpanded = false;
  bool _isFloatingOpen = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _avatarKey = GlobalKey();
  bool _isInitializingSized = false;

  void _setInitCompleteCallback() {
    if (!mounted) return;

    final WidgetMode widgetMode = widget.config?.widgetMode ?? WidgetMode.full;
    final SizedConfig? sizedConfig = widget.config?.sizedConfig;

    if (widgetMode == WidgetMode.sized &&
        sizedConfig != null &&
        sizedConfig.initiallyExpanded) {
      _isInitializingSized = true;
      if (Get.isRegistered<ChatController>()) {
        final controller = Get.find<ChatController>();
        // Set callback to expand when first init completes
        controller.setOnFirstInitCompleteCallback(() {
          if (mounted) {
            // Use addPostFrameCallback to ensure state update happens on next frame
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _isInitializingSized = false;
                  _isExpanded = true;
                });
              }
            });
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // For initiallyExpanded mode, start initialization and show skeleton
    if (widget.config != null) {
      final WidgetMode widgetMode = widget.config!.widgetMode;
      final SizedConfig? sizedConfig = widget.config!.sizedConfig;

      if (widgetMode == WidgetMode.sized &&
          sizedConfig != null &&
          sizedConfig.initiallyExpanded) {
        // Try to set callback immediately if ChatController exists
        _setInitCompleteCallback();
        // Also set it after first frame in case ChatController is created in build()
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _setInitCompleteCallback();
        });
      }
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    super.dispose();
  }

  void _collapseChat() {
    if (mounted) {
      setState(() {
        _isExpanded = false;
      });
    }
  }

  void _removeFloatingChat() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    // Only update state if widget is still mounted and not being disposed
    if (mounted) {
      setState(() {
        _isFloatingOpen = false;
      });
    }
  }

  void _showFloatingChat(BuildContext context) {
    // Remove existing overlay if any
    _removeFloatingChat();

    // Initialize binding before showing overlay
    if (widget.config != null) {
      ChatBinding(config: widget.config).dependencies();
    }

    // Get FloatingConfig - if not provided, use defaults
    final floatingConfig = widget.config?.floatingConfig;
    if (floatingConfig == null) {
      // If no config provided, fall back to old behavior (full screen from avatar position)
      return;
    }

    // Get the avatar widget's position BEFORE hiding it
    final RenderBox? renderBox =
        _avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Now hide the avatar by setting floating overlay as open
    setState(() {
      _isFloatingOpen = true;
    });

    final overlay = Overlay.of(context);
    final size = MediaQuery.of(context).size;

    // Get the avatar's position in global coordinates
    final avatarPosition = renderBox.localToGlobal(Offset.zero);
    final avatarSize = renderBox.size;

    // Calculate avatar corner positions
    final avatarTopLeft = avatarPosition;
    final avatarTopRight = Offset(
      avatarPosition.dx + avatarSize.width,
      avatarPosition.dy,
    );
    final avatarBottomLeft = Offset(
      avatarPosition.dx,
      avatarPosition.dy + avatarSize.height,
    );
    final avatarBottomRight = Offset(
      avatarPosition.dx + avatarSize.width,
      avatarPosition.dy + avatarSize.height,
    );

    // Calculate overlay position based on anchor
    double? left, top, right, bottom;

    switch (floatingConfig.anchor) {
      case FloatingAnchor.bottomRight:
        // Overlay's bottom-right aligns with avatar's bottom-right
        right = size.width - avatarBottomRight.dx;
        bottom = size.height - avatarBottomRight.dy;
        break;
      case FloatingAnchor.bottomLeft:
        // Overlay's bottom-left aligns with avatar's bottom-left
        left = avatarBottomLeft.dx;
        bottom = size.height - avatarBottomLeft.dy;
        break;
      case FloatingAnchor.topRight:
        // Overlay's top-right aligns with avatar's top-right
        right = size.width - avatarTopRight.dx;
        top = avatarTopRight.dy;
        break;
      case FloatingAnchor.topLeft:
        // Overlay's top-left aligns with avatar's top-left
        left = avatarTopLeft.dx;
        top = avatarTopLeft.dy;
        break;
    }

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: overlayContext,
          child: Positioned(
            left: left,
            top: top,
            right: right,
            bottom: bottom,
            width: floatingConfig.width,
            height: floatingConfig.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Transparent background that doesn't block interaction
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // Chat widget wrapped in MaterialApp to create separate overlay context for modals
                  Positioned.fill(
                    child: Builder(
                      builder: (builderContext) {
                        return MaterialApp(
                          debugShowCheckedModeBanner: false,
                          theme: Theme.of(overlayContext),
                          home: PupauAgentChat(
                            config: widget.config,
                            onCollapse: () => _removeFloatingChat(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    DeviceService.initializeTabletCheck(context);
    PupauConfig? config = widget.config;
    if (config == null) return const SizedBox();

    WidgetMode widgetMode = config.widgetMode;

    if (!Get.isRegistered<ChatController>()) {
      ChatBinding(config: config).dependencies();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setInitCompleteCallback();
      });
    }

    // For sized mode with initiallyExpanded, show skeleton while initializing
    if (widgetMode == WidgetMode.sized && _isInitializingSized) {
      final SizedConfig? sizedConfig = config.sizedConfig;
      return SizedBox(
        width: sizedConfig?.width,
        height: sizedConfig?.height,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),
          home: ChatSkeleton(config: widget.config),
        ),
      );
    }

    // In FULL mode or FLOATING mode when not expanded and overlay not open, show avatar
    if (widgetMode == WidgetMode.full ||
        (widgetMode == WidgetMode.floating && !_isFloatingOpen) ||
        (widgetMode == WidgetMode.sized && !_isExpanded)) {
      // Ensure AssistantsController exists
      if (!Get.isRegistered<AssistantsController>()) {
        ChatBinding().dependencies();
      }
      final assistantsController = Get.find<AssistantsController>();
      if (assistantsController.assistants.isEmpty) {
        assistantsController.getAssistants();
      }

      return Obx(() {
        // ignore: invalid_use_of_protected_member
        assistantsController.assistants.value;
        final Assistant? assistant = assistantsController.getAssistantById(
          config.assistantId,
          config.isMarketplace
              ? AssistantType.marketplace
              : AssistantType.assistant,
        );
        String imageUuid = assistant?.imageUuid ?? "";

        return InkWell(
          key: _avatarKey,
          onTap: () {
            // Initialize binding and reset state before navigation
            if (widget.config != null) {
              ChatBinding(config: widget.config).dependencies();
              if (Get.isRegistered<ChatController>()) {
                final controller = Get.find<ChatController>();
                if (widgetMode == WidgetMode.full) {
                  controller.openChatWithConfig(widget.config);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PupauAgentChat(config: widget.config),
                    ),
                  );
                } else if (widgetMode == WidgetMode.floating) {
                  controller.openChatWithConfig(widget.config);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showFloatingChat(context);
                  });
                } else if (widgetMode == WidgetMode.sized) {
                  controller.openChatWithConfig(widget.config);
                  setState(() {
                    _isExpanded = true;
                  });
                }
              }
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: AssistantAvatar(
            assistantId: widget.config?.assistantId ?? "",
            imageUuid: imageUuid,
            radius: widget.radius,
            format: widget.format,
            isMarketplaceUrl: widget.config?.isMarketplace ?? false,
          ),
        );
      });
    }

    // If floating mode is open, hide the avatar (overlay is shown separately)
    if (widgetMode == WidgetMode.floating && _isFloatingOpen) {
      return const SizedBox.shrink();
    }

    // Show expanded chat for SIZED mode - use configured width and height
    if (widgetMode == WidgetMode.sized && _isExpanded) {
      final SizedConfig? sizedConfig = config.sizedConfig;
      final Widget baseChatWidget = PupauAgentChat(
        config: widget.config,
        onCollapse: _collapseChat,
      );

      // For sized mode, wrap in MaterialApp to create separate overlay context for dialogs
      Widget chatWidget;
      if (sizedConfig != null) {
        chatWidget = SizedBox(
          width: sizedConfig.width,
          height: sizedConfig.height,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: Theme.of(context),
            home: baseChatWidget,
          ),
        );
      } else {
        chatWidget = MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),
          home: baseChatWidget,
        );
      }

      return chatWidget;
    }

    // Should not reach here for sized mode, but return empty if it does
    return const SizedBox.shrink();
  }
}
