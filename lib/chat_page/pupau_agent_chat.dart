import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_bottom_button.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_app_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_tools_fab.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/empty_conversation_view.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/empty_conversation_view_skeleton.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/messages_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/api_error_widget.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_bindings.dart';

class PupauAgentChat extends StatefulWidget {
  final PupauConfig? config;
  final VoidCallback? onCollapse;

  /// When true, [initState] does not call [PupauChatController.openChatWithConfig]
  /// (the host already did, e.g. [PupauChatUtils.openChat] before [Navigator.push]).
  /// [State.activate] still re-opens after [deactivate] so the same assistant can
  /// be reset when returning to a kept-alive route.
  final bool skipOpenChatOnAttach;

  const PupauAgentChat({
    super.key,
    this.config,
    this.onCollapse,
    this.skipOpenChatOnAttach = false,
  });

  @override
  State<PupauAgentChat> createState() => _PupauAgentChatState();
}

class _PupauAgentChatState extends State<PupauAgentChat> {
  bool _wasDeactivated = false;

  Future<void> _openChatAndSetCollapse() async {
    if (!mounted) return;
    if (!Get.isRegistered<PupauChatController>()) return;
    try {
      final PupauChatController controller = Get.find<PupauChatController>();
      if (widget.config != null) {
        await controller.openChatWithConfig(widget.config);
      }
      final WidgetMode widgetMode =
          widget.config?.widgetMode ?? WidgetMode.full;
      if (widgetMode == WidgetMode.sized || widgetMode == WidgetMode.floating) {
        controller.setCollapseCallback(widget.onCollapse);
      }
    } catch (_) {}
  }

  void _scheduleCollapseOnly() {
    Future<void>.microtask(() async {
      if (!mounted) return;
      if (!Get.isRegistered<PupauChatController>()) return;
      try {
        final PupauChatController controller = Get.find<PupauChatController>();
        final WidgetMode widgetMode =
            widget.config?.widgetMode ?? WidgetMode.full;
        if (widgetMode == WidgetMode.sized ||
            widgetMode == WidgetMode.floating) {
          controller.setCollapseCallback(widget.onCollapse);
        }
      } catch (_) {}
    });
  }

  void _scheduleOpenChatAndCollapse({required bool fromInitState}) {
    if (widget.config == null) return;
    if (fromInitState && widget.skipOpenChatOnAttach) {
      _scheduleCollapseOnly();
      return;
    }
    Future<void>.microtask(() async {
      if (!mounted) return;
      await _openChatAndSetCollapse();
    });
  }

  @override
  void initState() {
    super.initState();
    // Initialize binding with config if provided
    if (widget.config != null) {
      ChatBinding(config: widget.config).dependencies();
    } else {
      ChatBinding().dependencies();
    }

    // Run as early as possible after binding (not post-frame) so the controller
    // resets before the first paint when the host does not pre-call [openChatWithConfig].
    _scheduleOpenChatAndCollapse(fromInitState: true);
  }

  @override
  void activate() {
    super.activate();
    if (!_wasDeactivated) {
      // First insertion: [initState] already scheduled [openChatWithConfig] when needed.
      if (widget.skipOpenChatOnAttach) {
        _scheduleCollapseOnly();
      }
      return;
    }
    _scheduleOpenChatAndCollapse(fromInitState: false);
  }

  @override
  void deactivate() {
    _wasDeactivated = true;
    if (Get.isRegistered<PupauChatController>()) {
      try {
        Get.find<PupauChatController>().exitVoiceModeIfActive();
      } catch (_) {}
    }
    super.deactivate();
  }

  @override
  void didUpdateWidget(PupauAgentChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update config if it changed when widget rebuilds (e.g., switching agents)
    // This handles cases where the same widget instance is updated with a new config
    if (widget.config != oldWidget.config && widget.config != null) {
      if (Get.isRegistered<PupauChatController>()) {
        try {
          final controller = Get.find<PupauChatController>();
          // Await to ensure previous initialization completes before starting new one
          controller.openChatWithConfig(widget.config);
        } catch (_) {
          // Controller not available
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PupauAgentChatView(
      config: widget.config,
      onCollapse: widget.onCollapse,
    );
  }
}

class _PupauAgentChatView extends GetView<PupauChatController> {
  final PupauConfig? config;
  final VoidCallback? onCollapse;

  const _PupauAgentChatView({this.config, this.onCollapse});

  @override
  Widget build(BuildContext context) {
    DeviceService.initializeTabletCheck(context);
    bool isTablet = DeviceService.isTablet;
    DrawerConfig? drawerConfig = config?.drawerConfig;
    controller.setModalContext(context);

    return Obx(() {
      final bool embeddedDashboardOpen =
          controller.isEmbeddedChatDashboardOpen.value;
      return PopScope(
        canPop: !embeddedDashboardOpen,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (!didPop && controller.tryCloseEmbeddedChatDashboard()) {
            return;
          }
          if (didPop) {
            controller.stopActiveStreams();
            controller.ttsService.stopReading();
          }
        },
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is UserScrollNotification) {
              if (notification.direction != ScrollDirection.idle) {
                controller.suspendAutoScroll();
              } else if (controller.isAtBottom.value) {
                controller.clearAutoScrollSuspension();
              }
            } else if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              controller.suspendAutoScroll();
            }
            return true;
          },
          child: Obx(() {
            final bool isAnonymous = controller.isAnonymous;
            final bool hasApiError = controller.hasApiError.value;
            final bool isAdvanced = controller.isAdvanced();
            return Theme(
              data: ThemeData(
                brightness: isAnonymous || Get.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
                iconTheme: const IconThemeData(weight: 600),
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.of(context).padding.copyWith(
                    top: config?.widgetMode == WidgetMode.full ? 48 : 20,
                  ),
                ),
                child: Scaffold(
                  key: drawerConfig?.scaffoldKey,
                  backgroundColor: isAnonymous
                      ? AnonymousThemeColors.background
                      : MyStyles.pupauTheme(!Get.isDarkMode).white,
                  appBar: ChatAppBar(
                    isAnonymous: isAnonymous,
                    onBackPressed: () {
                      if (controller.tryCloseEmbeddedChatDashboard()) return;
                      controller.stopActiveStreams();
                      onCollapse?.call();
                    },
                    config: config,
                  ),
                  drawer: drawerConfig?.drawer,
                  endDrawer: drawerConfig?.endDrawer,
                  onDrawerChanged: drawerConfig?.onDrawerChanged,
                  onEndDrawerChanged: drawerConfig?.onEndDrawerChanged,
                  body: Builder(
                    builder: (scaffoldBodyContext) {
                      controller.setScaffoldContext(scaffoldBodyContext);
                      final WidgetMode shellMode = controller.widgetMode;
                      final Widget chatStack = Padding(
                        padding: EdgeInsets.only(
                          bottom: shellMode == WidgetMode.full ? 12 : 15,
                        ),
                        child: SafeArea(
                          top: false,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Expanded(
                                    child: hasApiError
                                        ? ApiErrorWidget(
                                            message: Strings.apiErrorGeneric.tr,
                                            retryAction: () =>
                                                controller.initChatController(),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 60,
                                            ),
                                          )
                                        : Obx(() {
                                            final bool messagesEmpty =
                                                controller.messages.isEmpty;
                                            final bool conversationLoading =
                                                controller
                                                    .isLoadingConversation
                                                    .value;
                                            final bool entryResolving =
                                                controller
                                                    .isChatEntryResolving
                                                    .value;
                                            // Chat screen is already open (see
                                            // PupauChatUtils.openChat / PupauAgentAvatar) while
                                            // assistant/conversation data is still loading —
                                            // show a skeleton instead of a blank/empty screen.
                                            if (messagesEmpty &&
                                                (conversationLoading ||
                                                    entryResolving)) {
                                              return const EmptyConversationViewSkeleton();
                                            }
                                            if (messagesEmpty) {
                                              return const EmptyConversationView();
                                            }
                                            return const MessagesList();
                                          }),
                                  ),
                                  const ChatInputField(),
                                ],
                              ),
                              const ChatBottomButton(),
                              if (isAdvanced && !controller.isVoiceMode.value)
                                Positioned(
                                  left: 12.5,
                                  bottom: isTablet ? 12 : 4,
                                  child: ChatToolsFAB(),
                                ),
                            ],
                          ),
                        ),
                      );
                      if (shellMode == WidgetMode.full) {
                        return chatStack;
                      }
                      return Navigator(
                        key: controller.chatShellNavigatorKey,
                        initialRoute: '/',
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute<void>(
                            settings: settings,
                            builder: (BuildContext context) => chatStack,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}
