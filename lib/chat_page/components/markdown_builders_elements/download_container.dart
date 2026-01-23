import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class DownloadContainer extends GetView<ChatController> {
  const DownloadContainer({
    super.key,
    required this.format,
    required this.id,
    required this.text,
  });

  final String format;
  final String id;
  final String text;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    AttachmentsController attachmentsController = Get.find();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Obx(() {
        bool isAnonymous = controller.isAnonymous;
        bool isDownloading =
            // ignore: invalid_use_of_protected_member
            attachmentsController.downloadingAttachments.value.contains(id);
        return Material(
          color: isAnonymous
              ? Colors.white
              : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: () => isDownloading ? null : attachmentsController.downloadAttachment(id),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.file_download,
                    size: isTablet ? 24 : 20,
                    color: isAnonymous
                        ? Colors.black87
                        : MyStyles.pupauTheme(!Get.isDarkMode).white,
                  ),
                  const SizedBox(width: 12),
                  // Content
                  Flexible(
                    child: Text(
                      text.isNotEmpty ? text : Strings.download.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 16 : 14,
                        color: isAnonymous
                            ? Colors.black87
                            : MyStyles.pupauTheme(!Get.isDarkMode).white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  if (isDownloading)
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: SizedBox(
                        width: isTablet ? 16 : 14,
                        height: isTablet ? 16 : 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: isAnonymous
                              ? Colors.black87
                              : MyStyles.pupauTheme(!Get.isDarkMode).white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
