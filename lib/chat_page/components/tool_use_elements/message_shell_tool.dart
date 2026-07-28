import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/code_block.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

/// Renders the `shell` native tool (nativeTool.id == "SHELL"): runs a bash
/// command inside the assistant's sandbox VM. Command/stdout/stderr are
/// always expanded and rendered with [CodeBlock] (the same dark
/// code-with-copy-button box used for fenced markdown code) rather than an
/// expand/collapse section, since shell I/O reads as code/terminal output.
class MessageShellTool extends StatelessWidget {
  const MessageShellTool({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final data = toolUseMessage?.shellData;
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

    final bool hasStdout = data.stdout.trim().isNotEmpty;
    final bool hasStderr = data.stderr.trim().isNotEmpty;
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
            if (!data.success || data.exitCode != 0) ...[
              Text('  •  ', style: secondaryTextStyle),
              Text('exit ${data.exitCode}', style: secondaryTextStyle),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(Strings.shellCommandLabel.tr, style: labelStyle),
        const SizedBox(height: 6),
        if (data.command.trim().isEmpty)
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
          CodeBlock(text: data.command, language: 'bash'),
        const SizedBox(height: 10),
        Text(Strings.result.tr, style: labelStyle),
        const SizedBox(height: 6),
        if (hasStdout) CodeBlock(text: data.stdout),
        if (!hasStdout && !hasStderr)
          Text(
            Strings.noOutput.tr,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: Get.isDarkMode || isAnonymous
                  ? Colors.white60
                  : Colors.black54,
            ),
          ),
        if (hasStderr) ...[
          if (hasStdout) const SizedBox(height: 10),
          Text(
            Strings.errors.tr,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
            ),
          ),
          const SizedBox(height: 6),
          CodeBlock(text: data.stderr),
        ],
      ],
    );
  }
}
