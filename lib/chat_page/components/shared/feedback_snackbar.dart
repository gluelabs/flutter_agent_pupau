import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

void showFeedbackSnackbar(
  String text,
  IconData icon, {
  bool flipX = false,
  bool flipY = false,
  bool isInfo = false,
}) {
  final Color backgroundColor = isInfo
      ? MyStyles.pupauTheme(!Get.isDarkMode).blueInfo
      : MyStyles.pupauTheme(!Get.isDarkMode).green;

  // Prefer the original GetX snackbar when the overlay is available (e.g. host
  // app uses GetMaterialApp). This preserves the exact GetX snackbar behavior.
  if (Get.overlayContext != null) {
    Get.snackbar(
      '',
      '',
      duration: const Duration(seconds: 5),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.only(right: 20, left: 20, top: 6, bottom: 12),
      barBlur: 5,
      messageText: Row(
        children: [
          Transform.flip(
            flipX: flipX,
            flipY: flipY,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      onTap: (snack) {
        Get.closeCurrentSnackbar();
      },
      titleText: const SizedBox(),
      snackPosition: SnackPosition.TOP,
    );
    return;
  }

  // Fallback for host apps that do not use GetX navigation / GetMaterialApp.
  // Use ScaffoldMessenger with styling that closely matches GetX snackbar.
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
    margin: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: bottomMargin),
    duration: const Duration(seconds: 5),
    content: Row(
      children: [
        Transform.flip(
          flipX: flipX,
          flipY: flipY,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
