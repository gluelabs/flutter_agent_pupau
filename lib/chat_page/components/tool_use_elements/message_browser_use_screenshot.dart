import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_bottom_info.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';

class MessageBrowserUseScreenshot extends GetView<ChatController> {
  const MessageBrowserUseScreenshot({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    String? screenshot =
        toolUseMessage?.browserUseData?.screenshot?.split(',').last;
      bool isAlreadyCached = screenshot != null &&
        controller.cachedToolUseImages.containsKey(screenshot);
    Uint8List? imageBytes = screenshot == null
        ? null
        : isAlreadyCached
            ? controller.cachedToolUseImages[screenshot]
            : (base64Decode(screenshot));
    if (!isAlreadyCached && imageBytes != null) {
      controller.cachedToolUseImages.addAll({screenshot!: imageBytes});
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return InkWell(
              onTap: () {
                if (screenshot != null) {
                  controller.selectImage(screenshot, ImageType.base64);
                }
              },
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * 0.5,
                child: imageBytes != null
                    ? Image.memory(imageBytes,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) =>
                            ImageNotAvailableWidget())
                    : ImageNotAvailableWidget(),
              ),
            );
          },
        ),
        BrowserUseBottomInfo(
            browserUseData: toolUseMessage?.browserUseData,
            isAnonymous: isAnonymous),
      ],
    );
  }
}
