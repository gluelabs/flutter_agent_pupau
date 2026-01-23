import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';

class AttachmentsTokensInfo extends GetView<AttachmentsController> {
  const AttachmentsTokensInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      int tokensUsed = AttachmentService.getTokensUsed(controller.attachments);
      bool hasAttachments = controller.attachments.isNotEmpty ||
          controller.sendingAttachments.value > 0;
      return hasAttachments
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 14, right: 14, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Strings.totalResources.tr,
                        style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color:
                                MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                      ),
                      Text(
                        "$tokensUsed tokens",
                        style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color:
                                MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 14, right: 14, bottom: 20),
                  child: Text(
                    Strings.totalResourcesFlavor.tr,
                    style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
              child: Text(
                Strings.contextResourcesInfo.tr,
                style: TextStyle(
                    fontSize: isTablet ? 15 : 13, fontWeight: FontWeight.w300),
              ),
            );
    });
  }
}
