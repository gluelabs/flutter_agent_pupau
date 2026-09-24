import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_import_attachment_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Renders the `import_attachment` native tool (nativeTool.id ==
/// "IMPORT_ATTACHMENT"): copies an existing chat attachment into the
/// assistant's sandbox VM workspace. Same layout as [MessageAttachArtifact]:
/// `name` (`size`), then "Imported into the workspace at `path`" below —
/// the workspace path, not the source name, since the tool can rename the
/// file on import.
class MessageImportAttachment extends StatelessWidget {
  const MessageImportAttachment({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseImportAttachmentData? data =
        toolUseMessage?.importAttachmentData;
    if (data == null) return const SizedBox.shrink();
    final bool isDark = Get.isDarkMode || isAnonymous;

    if (!data.success) {
      final String errorText = data.error.trim().isNotEmpty
          ? data.error.trim()
          : Strings.toolImportToSandboxFailedTitle.tr;
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
              errorText,
              style: StyleService.toolHeaderTextStyle(isDark),
            ),
          ),
        ],
      );
    }

    final String displayName = data.fileName.trim().isNotEmpty
        ? data.fileName.trim()
        : data.requestedPath.trim();
    final String workspacePath = data.path.trim().isNotEmpty
        ? data.path.trim()
        : data.requestedPath.trim();

    final TextStyle normalStyle = StyleService.toolNormalTextStyle(isDark);
    // @path is at a different position per language (e.g. Korean/Turkish
    // put it before the rest of the sentence), so split on the placeholder
    // rather than assuming it's a trailing suffix.
    final List<String> subtitleParts = Strings.toolImportedSubtitle.tr.split(
      '@path',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('📎 ', style: StyleService.toolHeaderTextStyle(isDark)),
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
                style: normalStyle,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: subtitleParts.first, style: normalStyle),
              TextSpan(
                text: workspacePath,
                style: normalStyle.copyWith(fontFamily: 'monospace'),
              ),
              if (subtitleParts.length > 1)
                TextSpan(
                  text: subtitleParts.sublist(1).join('@path'),
                  style: normalStyle,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
