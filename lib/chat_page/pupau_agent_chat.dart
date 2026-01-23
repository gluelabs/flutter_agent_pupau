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
    if (Get.isRegistered<ChatController>()) {
      try {
        final controller = Get.find<ChatController>();
        WidgetMode widgetMode = widget.config?.widgetMode ?? WidgetMode.full;
        if (widgetMode == WidgetMode.sized ||
            widgetMode == WidgetMode.floating) {
          controller.setCollapseCallback(widget.onCollapse);
        }
      } catch (_) {
        // Controller will be created on first access
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

class _PupauAgentChatView extends GetView<ChatController> {
  final PupauConfig? config;
  final VoidCallback? onCollapse;

  const _PupauAgentChatView({this.config, this.onCollapse});

  @override
  Widget build(BuildContext context) {
    DeviceService.initializeTabletCheck(context);
    bool isTablet = DeviceService.isTablet;
    controller.setModalContext(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) =>
          controller.ttsService.stopReading(),
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
          bool isFullMode = controller.widgetMode == WidgetMode.full;
          return Theme(
            data: ThemeData(
              brightness: isAnonymous || Get.isDarkMode
                  ? Brightness.dark
                  : Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: isAnonymous
                  ? AnonymousThemeColors.background
                  : MyStyles.pupauTheme(!Get.isDarkMode).white,
              appBar: ChatAppBar(
                isAnonymous: isAnonymous,
                onBackPressed: onCollapse,
                widgetMode: controller.widgetMode,
              ),
              body: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: !isFullMode ? 16 : 0),
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
              ),
            ),
          );
        }),
      ),
    );
  }
}
