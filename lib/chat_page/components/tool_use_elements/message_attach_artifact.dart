import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/attachment_image_inline.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
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
/// chat as a real conversation attachment. On success: 📎 `name` (`size`),
/// then "Saved as a conversation attachment" below — tappable when
/// `attachmentId` is present, opening the same attachment preview modal used
/// for normal conversation attachments ([document_tool_card.dart]'s exact
/// pattern: [PupauAttachmentsController.openAttachmentNoteModal]).
class MessageAttachArtifact extends GetView<PupauAttachmentsController> {
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
      final String errorText = data.error.trim().isNotEmpty
          ? data.error.trim()
          : Strings.toolArtifactAttachFailedTitle.tr;
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
        : data.path.trim();
    final bool isTappable = data.attachmentId.trim().isNotEmpty;
    final bool isImage =
        isTappable && _hasImageExtension(displayName);

    final Widget nameRow = Row(
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
            style: StyleService.toolNormalTextStyle(isDark),
          ),
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isTappable
            ? InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () async {
                  final attachment = await controller.getAttachmentById(
                    data.attachmentId.trim(),
                  );
                  if (attachment != null) {
                    controller.openAttachmentNoteModal(
                      attachment,
                      isEditable: false,
                    );
                  }
                },
                child: nameRow,
              )
            : nameRow,
        const SizedBox(height: 4),
        Text(
          Strings.toolArtifactSavedSubtitle.tr,
          style: StyleService.toolNormalTextStyle(isDark),
        ),
        if (isImage) ...[
          const SizedBox(height: 8),
          AttachmentImageInline(
            key: ValueKey<String>('artifact_img_${data.attachmentId.trim()}'),
            attachmentId: data.attachmentId.trim(),
            maxHeight: 260,
          ),
        ],
      ],
    );
  }

  static const Set<String> _imageExtensions = <String>{
    'png',
    'jpg',
    'jpeg',
    'webp',
    'gif',
    'heic',
    'heif',
  };

  bool _hasImageExtension(String name) {
    final int dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return false;
    return _imageExtensions.contains(name.substring(dot + 1).toLowerCase());
  }
}
