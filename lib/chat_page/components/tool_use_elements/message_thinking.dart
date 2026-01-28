import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';

class MessageThinking extends GetView<ChatController> {
  const MessageThinking({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    String thought =
        toolUseMessage?.thinkingData?.thought ?? Strings.thinking.tr;
    return CustomSelectableText(text: thought, isAnonymous: isAnonymous);
  }
}
