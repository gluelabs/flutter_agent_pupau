import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class AttachmentsBox extends GetView<PupauChatController> {
  const AttachmentsBox({super.key, required this.attachments});

  final List<Attachment> attachments;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    final List<Attachment> attachments = this.attachments
        .where((attachment) => attachment.link == "")
        .toList();
    final bool isAnonymous = controller.isAnonymous;
    final Color itemsColor = isAnonymous
        ? AnonymousThemeColors.assistantText
        : (MyStyles.getTextTheme(
            isLightTheme: !Get.isDarkMode,
          ).bodyMedium?.color)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.only(top: 12, left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: MyStyles.pupauTheme(!Get.isDarkMode).grey.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(attachments.length, (index) {
              Attachment attachment = attachments[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      FileService.getFileIcon(extension(attachment.fileName)),
                      color: itemsColor,
                      size: isTablet ? 28 : 24,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        attachment.fileName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: itemsColor,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
