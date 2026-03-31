import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

/// A widget that shows a context menu when the user long presses or right clicks on the widget.
class MyContextMenuRegion extends StatelessWidget {
  final ContextMenu contextMenu;
  final Widget child;
  final void Function(dynamic value)? onItemSelected;

  const MyContextMenuRegion({
    super.key,
    required this.contextMenu,
    required this.child,
    this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    Offset mousePosition = Offset.zero;

    return Listener(
      onPointerDown: (event) {
        mousePosition = event.position;
      },
      child: GestureDetector(
        onSecondaryTap: () => _showMenu(context, mousePosition),
        onDoubleTap: () => _showMenu(context, mousePosition),
        child: child,
      ),
    );
  }

  void _showMenu(BuildContext context, Offset mousePosition) async {
    bool isDone = PupauSharedPreferences.getTutorialMessageMenuDone();
    if (!isDone) {
      PupauSharedPreferences.setTutorialMessageMenuDone(true);
      // Avoid Get.forceAppUpdate(): it can cause visible UI glitches / rebuild
      // cascades while messages are streaming. Just refresh chat UI.
      if (Get.isRegistered<PupauChatController>()) {
        final controller = Get.find<PupauChatController>();
        controller.messages.refresh();
        controller.update();
      }
    }
    if (mousePosition == Offset.zero) {
      mousePosition = Offset(DeviceService.width / 1.5, DeviceService.height / 2.5);
    }
    final menu = contextMenu.copyWith(
        position: contextMenu.position ?? mousePosition,
        boxDecoration: BoxDecoration(
          color: MyStyles.pupauTheme(!Get.isDarkMode).white,
        ));
    final value = await showContextMenu(context, contextMenu: menu);
    onItemSelected?.call(value);
  }
}
