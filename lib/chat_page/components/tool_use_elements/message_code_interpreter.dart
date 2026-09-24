import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/code_block.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_code_interpreter_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Renders the Code Interpreter tool (nativeTool.id == "CODE_INTERPRETER").
/// Code/Result are always expanded and rendered with [CodeBlock] (the same
/// dark code-with-copy-button box used for fenced markdown code and for
/// [MessageShellTool]) rather than an expand/collapse section.
class MessageCodeInterpreter extends GetView<PupauChatController> {
  const MessageCodeInterpreter({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final data = toolUseMessage?.codeInterpreterData;
    final bool isTablet = DeviceService.isTablet;
    final TextStyle labelStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode || isAnonymous ? Colors.white : Colors.black87,
    );
    final TextStyle secondaryTextStyle = TextStyle(
      fontSize: isTablet ? 14 : 13,
      color: Get.isDarkMode || isAnonymous ? Colors.white70 : Colors.black87,
    );

    if (data == null) {
      final String fallback =
          toolUseMessage?.nativeToolData?['message']?.toString() ?? '';
      return fallback.trim().isEmpty
          ? const SizedBox.shrink()
          : CustomSelectableText(text: fallback, isAnonymous: isAnonymous);
    }

    final bool hasOutput = data.output.trim().isNotEmpty;
    final bool hasErrors = data.errors.isNotEmpty;
    final Color statusColor = data.success
        ? MyStyles.pupauTheme(!Get.isDarkMode).green
        : MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              data.success ? Strings.success.tr : Strings.failed.tr,
              style: labelStyle.copyWith(color: statusColor),
            ),
            if (data.executionTimeMs > 0) ...[
              Text('  •  ', style: secondaryTextStyle),
              Text('${data.executionTimeMs}ms', style: secondaryTextStyle),
            ],
          ],
        ),
        if (data.language.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${Strings.language.tr}: ', style: labelStyle),
              Text(data.language.trim(), style: secondaryTextStyle),
            ],
          ),
        ],
        if (data.sandboxCreated) ...[
          const SizedBox(height: 8),
          _SandboxNote(
            text: Strings.toolSandboxCreatedBanner.tr,
            isAnonymous: isAnonymous,
          ),
        ],
        if (data.resumeFailed) ...[
          const SizedBox(height: 8),
          _SandboxNote(
            text: Strings.toolSandboxResumeFailedBanner.tr,
            isAnonymous: isAnonymous,
          ),
        ],
        const SizedBox(height: 12),
        Text(Strings.code.tr, style: labelStyle),
        const SizedBox(height: 6),
        if (data.code.trim().isEmpty)
          Text(
            Strings.noCodeProvided.tr,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Get.isDarkMode || isAnonymous
                  ? Colors.white60
                  : Colors.black54,
            ),
          )
        else
          CodeBlock(
            text: data.code,
            language: data.language.trim().isEmpty
                ? null
                : data.language.trim(),
          ),
        const SizedBox(height: 10),
        Text(Strings.result.tr, style: labelStyle),
        const SizedBox(height: 6),
        if (hasOutput) CodeBlock(text: data.output),
        if (!hasOutput && !hasErrors)
          Text(
            Strings.noOutput.tr,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Get.isDarkMode || isAnonymous
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
        if (hasErrors) ...[
          if (hasOutput) const SizedBox(height: 10),
          Text(
            Strings.errors.tr,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
            ),
          ),
          const SizedBox(height: 6),
          CodeBlock(text: data.errors.join('\n\n')),
        ],
        if (data.images.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(Strings.images.tr, style: labelStyle),
          const SizedBox(height: 6),
          for (final ToolUseCodeInterpreterImage image in data.images)
            if (image.isRenderableImage)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CodeInterpreterImage(
                  image: image,
                  isAnonymous: isAnonymous,
                  secondaryTextStyle: secondaryTextStyle,
                  controller: controller,
                ),
              ),
        ],
      ],
    );
  }
}

/// Small "Note"-style informational row (icon + text) for the
/// sandboxCreated/resumeFailed banners — same shape as the attachment
/// tools' soft-note pattern ([_AttachmentSoftNote] in
/// message_attachment_tool.dart), kept local here since it's a one-line
/// helper with no shared state to justify extracting further.
class _SandboxNote extends StatelessWidget {
  const _SandboxNote({required this.text, required this.isAnonymous});

  final String text;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Get.isDarkMode || isAnonymous;
    final Color color = isDark ? Colors.white70 : Colors.black54;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Symbols.info, color: color, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: CustomSelectableText(
            text: text,
            isAnonymous: isAnonymous,
            textStyle: TextStyle(
              fontSize: DeviceService.isTablet ? 14 : 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// Renders one [ToolUseCodeInterpreterImage] — the caller already filtered
/// to [ToolUseCodeInterpreterImage.isRenderableImage] entries, so this only
/// has to decide raster (tap-to-zoom, via the same
/// [PupauChatController.selectImage] flow as browser-use screenshots) vs.
/// SVG (inline vector, no zoom viewer support for that format today).
/// Decoding is wrapped so a corrupted/truncated payload degrades to
/// [ImageNotAvailableWidget] instead of crashing the message bubble.
class _CodeInterpreterImage extends StatelessWidget {
  const _CodeInterpreterImage({
    required this.image,
    required this.isAnonymous,
    required this.secondaryTextStyle,
    required this.controller,
  });

  final ToolUseCodeInterpreterImage image;
  final bool isAnonymous;
  final TextStyle secondaryTextStyle;
  final PupauChatController controller;

  @override
  Widget build(BuildContext context) {
    final String payload = image.base64Payload;
    final bool hasCaption = image.description.trim().isNotEmpty;

    Widget imageWidget;
    if (image.isSvg) {
      try {
        imageWidget = SvgPicture.memory(
          base64Decode(payload),
          fit: BoxFit.contain,
        );
      } catch (_) {
        imageWidget = const ImageNotAvailableWidget();
      }
    } else {
      final bool isAlreadyCached = controller.cachedToolUseImages.containsKey(
        payload,
      );
      Uint8List? bytes;
      try {
        bytes = isAlreadyCached
            ? controller.cachedToolUseImages[payload]
            : base64Decode(payload);
      } catch (_) {
        bytes = null;
      }
      if (!isAlreadyCached && bytes != null) {
        controller.cachedToolUseImages[payload] = bytes;
      }
      imageWidget = bytes == null
          ? const ImageNotAvailableWidget()
          : InkWell(
              onTap: () => controller.selectImage(payload, ImageType.base64),
              child: Image.memory(
                bytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) =>
                    const ImageNotAvailableWidget(),
              ),
            );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: imageWidget,
          ),
        ),
        if (hasCaption) ...[
          const SizedBox(height: 4),
          Text(image.description.trim(), style: secondaryTextStyle),
        ],
      ],
    );
  }
}
