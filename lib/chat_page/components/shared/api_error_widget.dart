import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

class ApiErrorWidget extends StatelessWidget {
  const ApiErrorWidget(
      {super.key,
      required this.message,
      required this.retryAction,
      this.padding});

  final String message;
  final Function() retryAction;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Container(
      padding: padding,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: isTablet ? 20 : 15, fontWeight: FontWeight.w500)),
            SizedBox(height: 15),
            SizedBox(
              width: DeviceService.width,
              child: CustomButton(
                  text: Strings.retry.tr, onPressed: () => retryAction()),
            ),
          ],
        ),
      ),
    );
  }
}
