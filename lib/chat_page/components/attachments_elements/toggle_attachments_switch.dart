import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_switch.dart';

import '../../../utils/translations/strings_enum.dart';

class ToggleAttachmentsSwitch extends GetView<AttachmentsController> {
  const ToggleAttachmentsSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      bool allAttachmentsDisabled = controller.allAttachmentsDisabled.value;
      bool hasAttachments = controller.attachments.isNotEmpty;
      return hasAttachments
          ? Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () => controller.toggleAllAttachments(),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(width: 6),
                        Text(
                            allAttachmentsDisabled
                                ? Strings.selectAll.tr
                                : Strings.deselectAll.tr,
                            style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500,
                                color: MyStyles.pupauTheme(!Get.isDarkMode)
                                    .darkBlue)),
                        Transform.scale(
                          scale: 0.7,
                          child: CustomSwitch(
                              isActive: !allAttachmentsDisabled,
                              onChanged: (_) =>
                                  controller.toggleAllAttachments()),
                        )
                      ]),
                ),
              ),
            )
          : const SizedBox();
    });
  }
}
