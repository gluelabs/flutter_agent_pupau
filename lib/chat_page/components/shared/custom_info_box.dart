import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';

Future<void> showInfoBox(String title, String subtitle) {
  bool isTablet = DeviceService.isTablet;
  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return Future.value();
  return showDialog<void>(
    context: safeContext,
    useRootNavigator: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          ),
        ),
        content: Text(subtitle, style: TextStyle(fontSize: isTablet ? 16 : 14)),
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        actions: <Widget>[
          TextButton(
            child: Text(
              'OK',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
