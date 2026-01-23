import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_browser_use_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_bottom_info.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';

class MessageBrowserUseNavigate extends GetView<ChatController> {
  const MessageBrowserUseNavigate({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    ToolUseBrowserUseData? browserUseData = toolUseMessage?.browserUseData;
    String? screenshot = browserUseData?.screenshot?.split(',').last;
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
    int actualWidth = browserUseData?.actualWidth ?? 0;
    int actualHeight = browserUseData?.actualHeight ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate optimal dimensions while maintaining aspect ratio
            double maxWidth = constraints.maxWidth;
            double maxHeight =
                maxWidth * 0.75; // Limit height to 75% of width for better UX

            double displayWidth = maxWidth;
            double displayHeight;

            if (actualWidth > 0 && actualHeight > 0) {
              // Calculate height based on actual aspect ratio
              double aspectRatio = actualWidth / actualHeight;
              displayHeight = displayWidth / aspectRatio;

              // If calculated height exceeds max height, scale down proportionally
              if (displayHeight > maxHeight) {
                double scaleFactor = maxHeight / displayHeight;
                displayWidth = displayWidth * scaleFactor;
                displayHeight = maxHeight;
              }
            } else {
              // Fallback to square if dimensions are not available
              displayHeight = maxWidth;
            }

            return SizedBox(
              width: displayWidth,
              height: displayHeight,
              child: imageBytes != null
                  ? InkWell(
                      onTap: () {
                        if (screenshot != null) {
                          controller.selectImage(screenshot, ImageType.base64);
                        }
                      },
                      child: Image.memory(imageBytes,
                          fit: BoxFit.contain,
                          gaplessPlayback: true,
                          errorBuilder: (context, error, stackTrace) =>
                              ImageNotAvailableWidget()),
                    )
                  : ImageNotAvailableWidget(),
            );
          },
        ),
        BrowserUseBottomInfo(
            browserUseData: browserUseData, isAnonymous: isAnonymous),
      ],
    );
  }
}
