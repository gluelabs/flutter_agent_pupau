import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

void showErrorSnackbar(String text) {
  final Color backgroundColor =
      MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;

  // Prefer original GetX snackbar when overlay is available (host app uses
  // GetMaterialApp), so behavior matches exactly.
  if (Get.overlayContext != null) {
    Get.snackbar(
      '',
      '',
      duration: const Duration(seconds: 5),
      backgroundColor: backgroundColor,
      padding:
          const EdgeInsets.only(right: 20, left: 20, top: 6, bottom: 12),
      barBlur: 5,
      messageText: SnackbarErrorContainer(text: text),
      titleText: const SizedBox(),
      onTap: (snack) {
        Get.closeCurrentSnackbar();
      },
      snackPosition: SnackPosition.TOP,
    );
    return;
  }

  // Fallback for host apps that do not use GetX navigation / GetMaterialApp.
  BuildContext? context;
  if (Get.isRegistered<PupauChatController>()) {
    context = Get.find<PupauChatController>().safeContext;
  }
  context ??= Get.context;
  if (context == null) return;

  final double bottomMargin = MediaQuery.of(context).size.height - 150;

  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: backgroundColor,
    elevation: 6,
    margin: EdgeInsets.only(
      left: 16,
      right: 16,
      top: 16,
      bottom: bottomMargin,
    ),
    duration: const Duration(seconds: 5),
    content: SnackbarErrorContainer(text: text),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class SnackbarErrorContainer extends StatelessWidget {
  const SnackbarErrorContainer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Row(
      children: [
        Icon(Symbols.error_outline_rounded,
            color: Colors.white, size: isTablet ? 32 : 26),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
