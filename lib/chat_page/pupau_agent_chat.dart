import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_app_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_tools_fab.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/messages_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/scroll_button.dart';
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

  const PupauAgentChat({super.key, this.config, this.onCollapse});

  @override
  State<PupauAgentChat> createState() => _PupauAgentChatState();
}

class _PupauAgentChatState extends State<PupauAgentChat> {
  @override
  void initState() {
    super.initState();
    // Initialize binding with config if provided
    if (widget.config != null) {
      ChatBinding(config: widget.config).dependencies();
    } else {
      ChatBinding().dependencies();
    }
    
    // Ensure config is updated when switching agents
    // This is critical for supporting multiple agents in the same app
    // Use postFrameCallback to ensure controller is ready (either newly created or reused)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Get.isRegistered<PupauChatController>()) {
        try {
          final controller = Get.find<PupauChatController>();
          // Always update config if provided - controller will wait for any ongoing initialization
          // This ensures that when switching agents, the config is properly updated after previous init completes
          if (widget.config != null) {
            await controller.openChatWithConfig(widget.config);
          }
          
          WidgetMode widgetMode = widget.config?.widgetMode ?? WidgetMode.full;
          if (widgetMode == WidgetMode.sized ||
              widgetMode == WidgetMode.floating) {
            controller.setCollapseCallback(widget.onCollapse);
          }
        } catch (_) {
          // Controller will be created on first access
        }
      }
    });
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
    
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) =>
          () {
        controller.stopActiveStreams();
        controller.ttsService.stopReading();
      },
      child: NotificationListener(
        onNotification: (notification) {
          if (notification is ScrollStartNotification &&
              notification.dragDetails != null) {
            controller.stopAutoScroll();
          }
          return true;
        },
        child: Obx(() {
          bool isAnonymous = controller.isAnonymous;
          bool hasApiError = controller.hasApiError.value;
          bool hasUserMessage = controller.messages.length > 1;
          bool scrollButtonVisible =
              hasUserMessage && !controller.isAtBottom.value;
          bool isAdvanced = controller.isAdvanced();
          return Theme(
            data: ThemeData(
              brightness: isAnonymous || Get.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
            ),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: MediaQuery.of(context).padding.copyWith(top: config?.widgetMode == WidgetMode.full ? 48 : 20),
              ),
              child: Scaffold(
                key: drawerConfig?.scaffoldKey,
                backgroundColor: isAnonymous
                    ? AnonymousThemeColors.background
                    : MyStyles.pupauTheme(!Get.isDarkMode).white,
                appBar: ChatAppBar(
                  isAnonymous: isAnonymous,
                  onBackPressed: () {
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
                    return Padding(
                      padding: EdgeInsets.only(bottom: controller.widgetMode == WidgetMode.full ? 24 : 15),
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              children: [
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
                                      : const MessagesList(),
                                ),
                                const ChatInputField(),
                              ],
                            ),
                            Transform.translate(
                              offset: Offset(
                                -12,
                                -controller.messageInputFieldHeight.value,
                              ),
                              child: ScrollButton(
                                toBottom: true,
                                isVisible: scrollButtonVisible,
                                onTap: () => controller.scrollToBottomChat(
                                  withAnimation: true,
                                ),
                                isAnonymous: isAnonymous,
                              ),
                            ),
                            if (isAdvanced)
                              Positioned(
                                left: 12.5,
                                bottom: isTablet ? 12 : 4,
                                child: ChatToolsFAB(),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
