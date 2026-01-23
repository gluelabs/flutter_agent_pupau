import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

void showErrorSnackbar(String text) {
  final BuildContext? context = getSafeModalContext();
  if (context == null) return;

  final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final bool isTablet = DeviceService.isTablet;
  final Color backgroundColor = MyStyles.pupauTheme(!isDarkMode).redAlarm;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          children: [
            Icon(
              Symbols.error_outline_rounded,
              color: Colors.white,
              size: isTablet ? 32 : 26,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
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
