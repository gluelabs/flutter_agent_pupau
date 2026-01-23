import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';

Future<void> showSettingDeniedDialog(String message) {
  bool isTablet = DeviceService.isTablet;
  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return Future.value();
  
  return showDialog<void>(
    context: safeContext,
    useRootNavigator: false,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        titlePadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(top: 20, right: 12, left: 12),
          child: Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: isTablet ? 20 : 16,
                  color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
        ),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 15),
            child: Row(
              spacing: 16,
              children: [
                CustomButton(
                  text: Strings.undo.tr,
                  isPrimary: false,
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                    child: CustomButton(
                  text: Strings.openAppSettings.tr,
                  onPressed: () {
                    Navigator.pop(context);
                    openAppSettings();
                  },
                )),
              ],
            ),
          ),
        ],
      );
    },
  );
}
