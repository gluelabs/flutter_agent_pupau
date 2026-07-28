import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_import_tool_result_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Renders the `import_tool_result` native tool (nativeTool.id ==
/// "IMPORT_TOOL_RESULT"): imports a previous large tool result (referenced
/// by a handle) into the assistant's sandbox VM workspace as a file. Same
/// layout as [MessageImportAttachment]: `path` (`size`), then "Imported
/// into the workspace at `path`" below — reuses the same strings since the
/// destination-side behavior is identical, only the source differs (a tool
/// result handle rather than a chat attachment).
class MessageImportToolResult extends StatelessWidget {
  const MessageImportToolResult({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseImportToolResultData? data =
        toolUseMessage?.importToolResultData;
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
              Strings.toolImportToSandboxFailedTitle.tr,
              style: StyleService.toolHeaderTextStyle(isDark),
            ),
          ),
        ],
      );
    }

    final String workspacePath = data.path.trim().isNotEmpty
        ? data.path.trim()
        : data.requestedPath.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                workspacePath,
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
          Strings.toolImportedSubtitle.tr.replaceAll('@path', workspacePath),
          style: StyleService.toolNormalTextStyle(isDark),
        ),
      ],
    );
  }
}