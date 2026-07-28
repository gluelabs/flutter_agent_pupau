import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_attach_artifact_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Renders the `attach_artifact` native tool (nativeTool.id ==
/// "ATTACH_ARTIFACT"): shares a file from the assistant's sandbox VM to the
/// chat as a real conversation attachment. On success: `name` (`size`),
/// then "Saved as a conversation attachment" below.
class MessageAttachArtifact extends StatelessWidget {
  const MessageAttachArtifact({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseAttachArtifactData? data = toolUseMessage?.attachArtifactData;
    if (data == null) return const SizedBox.shrink();
    final bool isDark = Get.isDarkMode || isAnonymous;

    if (!data.success) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.error,
            color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              Strings.toolArtifactAttachFailedTitle.tr,
              style: StyleService.toolHeaderTextStyle(isDark),
            ),
          ),
        ],
      );
    }

    final String displayName = data.fileName.trim().isNotEmpty
        ? data.fileName.trim()
        : data.path.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                displayName,
                overflow: TextOverflow.ellipsis,
                style: StyleService.toolHeaderTextStyle(isDark),
              ),
            ),
            if (data.sizeBytes > 0) ...[
              const SizedBox(width: 6),
              Text(
                '(${StringService.formatBytes(data.sizeBytes)})',
                style: StyleService.toolNormalTextStyle(isDark),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          Strings.toolArtifactSavedSubtitle.tr,
          style: StyleService.toolNormalTextStyle(isDark),
        ),
      ],
    );
  }
}
