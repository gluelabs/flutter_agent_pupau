import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class StopMessageButton extends GetView<PupauChatController> {
  const StopMessageButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      final bool stopIsActive = controller.isStreaming.value;
      final bool isStopping = controller.isStopping.value;
      if (!stopIsActive) return const SizedBox();
      final Color iconColor = isAnonymous
          ? Colors.black
          : MyStyles.pupauTheme(!Get.isDarkMode).primary;
      return Transform.translate(
        offset: const Offset(12, 0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Opacity(
              opacity: isStopping ? 0.5 : 1.0,
              child: IconButton(
                onPressed: isStopping ? null : () => controller.sendCancel(),
                tooltip: Strings.stop.tr,
                icon: Icon(
                  Symbols.stop,
                  size: 26,
                  color: isAnonymous ? Colors.black : iconColor,
                ),
              ),
            ),
            if (isStopping)
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                ),
              ),
          ],
        ),
      );
    });
  }
}
