import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_attachment_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Renders the result of the 5 JIT attachment tools (list_attachments,
/// attachment_outline, attachment_read, attachment_grep, attachment_search).
///
/// All 5 share the same result envelope (`message` + `info[]`), so this is a
/// single generic renderer rather than one widget per tool. Unknown/future
/// attachment tool names fall through to the same rendering — the ticket
/// requires the UI to never throw on an unrecognized `toolName`.
class MessageAttachmentTool extends StatelessWidget {
  const MessageAttachmentTool({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  static const Set<String> _monospaceTools = {
    'attachment_read',
    'attachment_grep',
  };

  @override
  Widget build(BuildContext context) {
    final ToolUseAttachmentData? data = toolUseMessage?.attachmentToolData;
    if (data == null) return const SizedBox.shrink();
    final bool isDark = Get.isDarkMode || isAnonymous;

    if (!data.success) {
      return _AttachmentSoftNote(
        message: data.displayMessage,
        isDark: isDark,
        isAnonymous: isAnonymous,
      );
    }

    final bool monospace = _monospaceTools.contains(data.toolName.trim());
    // Passing null keeps CustomSelectableText's own default style, which is
    // exactly what a normal chat message uses — guarantees size/family/color
    // parity (and the same left alignment) without duplicating it here.
    final TextStyle? textStyle = monospace
        ? _normalMessageTextStyle(isAnonymous).copyWith(fontFamily: 'monospace')
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (data.displayMessage.trim().isNotEmpty)
          SizedBox(
            width: double.infinity,
            child: CustomSelectableText(
              text: data.displayMessage,
              isAnonymous: isAnonymous,
              textStyle: textStyle,
            ),
          ),
        if (data.isTruncated) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: _TruncatedBadge(isDark: isDark),
          ),
        ],
        if (data.info.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 6,
              runSpacing: 6,
              children: data.info
                  .map((item) => _AttachmentInfoChip(item: item, isDark: isDark))
                  .toList(),
            ),
          ),
        ],
      ],
    );
  }
}

/// Matches the default text style [CustomSelectableText] uses for a normal
/// chat message body (same font size/color as regular assistant/user text).
TextStyle _normalMessageTextStyle(bool isAnonymous) => TextStyle(
  fontSize: DeviceService.isTablet ? 16 : 14,
  color: isAnonymous
      ? AnonymousThemeColors.assistantText
      : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode).bodyMedium?.color,
);

class _AttachmentSoftNote extends StatelessWidget {
  const _AttachmentSoftNote({
    required this.message,
    required this.isDark,
    required this.isAnonymous,
  });

  final String message;
  final bool isDark;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final Color color = isDark ? Colors.white70 : Colors.black54;
    final String safeMessage = message.trim().isEmpty
        ? Strings.attachmentToolSoftNoteTitle.tr
        : message.trim();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Symbols.info, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: CustomSelectableText(
            text: safeMessage,
            isAnonymous: isAnonymous,
          ),
        ),
      ],
    );
  }
}

class _TruncatedBadge extends StatelessWidget {
  const _TruncatedBadge({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final Color color = isDark ? Colors.white60 : Colors.black45;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Symbols.content_cut, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          Strings.attachmentToolTruncatedNote.tr,
          style: StyleService.toolNormalTextStyle(isDark).copyWith(
            fontStyle: FontStyle.italic,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _AttachmentInfoChip extends StatelessWidget {
  const _AttachmentInfoChip({required this.item, required this.isDark});

  final ToolUseAttachmentInfoItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final Color border = isDark
        ? Colors.white70
        : MyStyles.pupauTheme(!Get.isDarkMode).grey;
    return InkWell(
      onTap: () {
        if (Get.isRegistered<PupauAttachmentsController>()) {
          Get.find<PupauAttachmentsController>().openAttachmentsModal();
        }
      },
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FileService.getFileIcon(_extensionOf(item.fileName)),
              size: isTablet ? 16 : 14,
              color: isDark ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                item.fileName.isEmpty ? item.id : item.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: StyleService.toolNormalTextStyle(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _extensionOf(String fileName) {
  final int dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0 || dotIndex == fileName.length - 1) return '';
  return fileName.substring(dotIndex).toLowerCase();
}
