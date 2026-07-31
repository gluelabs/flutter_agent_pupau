import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/scroll_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatBottomButton extends GetView<PupauChatController> {
  const ChatBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isAtBottom = controller.isAtBottom.value;
      final bool magnetEnabled = controller.autoScrollMagnetEnabled.value;
      final bool isAnonymous = controller.isAnonymous;
      final double messageInputFieldHeight =
          controller.messageInputFieldHeight.value;
      return Transform.translate(
        offset: Offset(-12, -messageInputFieldHeight),
        child: ScrollButton(
          toBottom: true,
          isVisible: true,
          tooltip: isAtBottom
              ? (magnetEnabled
                    ? Strings.autoScrollMagnetOnTapToTurnOff.tr
                    : Strings.autoScrollMagnetOffTapToTurnOn.tr)
              : Strings.scrollToBottom.tr,
          keepSvgColor: magnetEnabled,
          svgAssetPath: isAtBottom
              ? (magnetEnabled
                    ? "${Constants.assetPath}/images/magnet_on.svg"
                    : "${Constants.assetPath}/images/magnet_off.svg")
              : null,
          icon: isAtBottom ? null : Symbols.arrow_downward,
          onTap: () => isAtBottom
              ? controller.toggleAutoScrollMagnet()
              : () {
                  controller.clearAutoScrollSuspension();
                  controller.scrollToBottomChat(withAnimation: true);
                }(),
          isAnonymous: isAnonymous,
        ),
      );
    });
  }
}
