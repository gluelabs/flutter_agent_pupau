import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/browser_use_bottom_info.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';

class MessageBrowserUseLoadingPlaceholder extends GetView<ChatController> {
  const MessageBrowserUseLoadingPlaceholder({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxWidth * 0.75,
                child: Image.asset(
                    '${Constants.assetPath}/gif/browser_loading.gif',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    gaplessPlayback: true,
                    errorBuilder: (context, error, stackTrace) =>
                        ImageNotAvailableWidget()));
          },
        ),
        BrowserUseBottomInfo(
            browserUseData: toolUseMessage?.browserUseData,
            isAnonymous: isAnonymous),
      ],
    );
  }
}
