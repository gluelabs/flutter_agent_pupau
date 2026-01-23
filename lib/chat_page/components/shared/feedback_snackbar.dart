import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

void showFeedbackSnackbar(String text, IconData icon,
    {bool flipX = false, bool flipY = false, bool isInfo = false}) {
  final BuildContext? context = getSafeModalContext();
  if (context == null) return;

  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final Color backgroundColor = isInfo
      ? MyStyles.pupauTheme(!isDarkMode).blueInfo
      : MyStyles.pupauTheme(!isDarkMode).green;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
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
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 
               MediaQuery.of(context).padding.top - 100,
        left: 24,
        right: 24,
      ),
      dismissDirection: DismissDirection.horizontal,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
