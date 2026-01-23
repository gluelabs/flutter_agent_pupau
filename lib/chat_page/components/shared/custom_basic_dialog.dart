import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

Future<void> showCustomBasicDialog(String text) async {
  bool isTablet = DeviceService.isTablet;
  BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return Future.value();
  
  return await showDialog<void>(
    context: safeContext,
    useRootNavigator: false,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
        title: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: isTablet ? 20 : 16,
                color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25))),
        actionsAlignment: MainAxisAlignment.center,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 15),
            child: SizedBox(
              width: isTablet ? 150 : 125,
              child: CustomButton(text: "Ok", onPressed: () => Navigator.pop(context)),
            ),
          ),
        ],
      );
    },
  );
}
