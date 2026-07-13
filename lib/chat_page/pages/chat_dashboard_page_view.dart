import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_list_view.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/basic_app_bar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class ChatDashboardPageView extends GetView<ChatDashboardController> {
  const ChatDashboardPageView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final PupauChatController chatController = Get.find<PupauChatController>();
    final bool isAnonymous = chatController.isAnonymous;
    final Color backgroundColor = isAnonymous
        ? AnonymousThemeColors.background
        : MyStyles.pupauTheme(!Get.isDarkMode).white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: BasicAppBar(title: Strings.chatDashboard.tr),
      body: SafeArea(
        child: Obx(() {
          final DashboardCanvasItem? canvasItem =
              controller.selectedCanvasItem.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: Duration.zero,
            transitionBuilder: (Widget child, Animation<double> animation) {
              final Animation<double> curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.08, -0.08),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
            child: canvasItem != null
                ? DashboardCanvas(
                    key: ValueKey<String>('canvas_${canvasItem.canvasId}'),
                    item: canvasItem,
                    isAnonymous: isAnonymous,
                  )
                : const DashboardListView(
                    key: ValueKey<String>('dashboard_list'),
                  ),
          );
        }),
      ),
    );
  }
}
