import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/ui_tool_elements/message_authorize_tool.dart';
import 'package:flutter_agent_pupau/chat_page/components/ui_tool_elements/message_request_credentials.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/services/ui_tool_service.dart';

class UiToolBubble extends GetView<PupauChatController> {
  const UiToolBubble({super.key, required this.message});

  final UiToolMessage message;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
    Theme.of(context);
      final bool isAnonymous = controller.isAnonymous;
      // Access observable directly to ensure GetX detects it
      // ignore: invalid_use_of_protected_member
      final bool isHidden = controller.hiddenUiToolMessages.value.contains(
        message.id,
      );
      return Visibility(
        visible: !isHidden,
        child: Material(
          color: StyleService.getBubbleColor(true, isAnonymous, false),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: DeviceService.width * 0.75,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.only(left: 6, right:  15, top: 8, bottom: 8),
            child: switch (message.type) {
              UiToolType.authorizeTool => MessageAuthorizeTool(
                message: message,
              ),
              UiToolType.requestCredentials => MessageRequestCredentials(
                message: message,
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ),
      );
    });
  }
}
