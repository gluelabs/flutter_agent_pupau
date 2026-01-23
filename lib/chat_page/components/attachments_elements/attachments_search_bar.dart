import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';

import '../../../utils/translations/strings_enum.dart';

class AttachmentsSearchBar extends GetView<AttachmentsController> {
  const AttachmentsSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Visibility(
      visible:
          controller.attachments.length >= controller.lengthToShowNoAttachments,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: SizedBox(
          height: 48,
          child: TextFormField(
            style: TextStyle(fontSize: isTablet ? 16 : 14),
            controller: controller.searchAttachmentsController,
            decoration: InputDecoration(
              border: StyleService.border(),
              enabledBorder: StyleService.border(),
              focusedBorder: StyleService.focusBorder(),
              disabledBorder: StyleService.border(),
              fillColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
              hintText: "${Strings.search.tr}...",
              hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              suffixIcon: Obx(() {
                bool isVisible = controller.searchAttachmentsText.value != "";
                return Visibility(
                  visible: isVisible,
                  child: IconButton(
                      onPressed: () {
                        controller.searchAttachmentsController.clear();
                        controller.searchAttachments("");
                      },
                      icon: Icon(Symbols.close, size: isTablet ? 26 : 24)),
                );
              }),
            ),
            onChanged: (String? value) => controller.searchAttachments(value),
          ),
        ),
      ),
    );
  }
}
