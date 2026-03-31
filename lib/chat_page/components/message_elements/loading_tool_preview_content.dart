import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/tool_args_delta_service.dart';
import 'package:get/get.dart';

class LoadingToolPreviewContent extends GetView<PupauChatController> {
  const LoadingToolPreviewContent({
    required this.toolName,
    super.key,
  });

  final String toolName;

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4),
      child: Obx(() {
        final String toolId = ToolArgsDeltaService.resolveToolIdByName(
          toolName: toolName,
          toolIdByName: controller.toolArgsPreviewToolIdByName,
        );
        if (toolId.isEmpty) return const SizedBox.shrink();
        final String raw =
            controller.getToolArgsPreviewContentByToolId(toolId).trim();
        final String content =
            (ToolArgsDeltaService.extractFirstJsonStringValue(
                      raw,
                    ) ??
                    raw)
                .trim();
        if (content.isEmpty) return const SizedBox.shrink();
        return CustomSelectableText(
          text: content,
          isAnonymous: isAnonymous,
        );
      }),
    );
  }
}
