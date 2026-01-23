import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class KnowledgeBaseInfo extends GetView<ChatController> {
  const KnowledgeBaseInfo(
      {super.key, required this.message, required this.onTap});

  final PupauMessage message;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    double fontSize = isTablet ? 16 : 13;
    return Obx(() {
      bool isAnonymous = controller.isAnonymous;
      KBSettings? kbSettings = controller.assistant.value?.kbSettings;
      bool showKbChip = kbSettings?.showKbChip ?? false;
      bool showKbResources = kbSettings?.showKbResources ?? false;
      bool hasKb = message.kbReferences.isNotEmpty;
      return Visibility(
        visible: hasKb && message.status != MessageStatus.loading,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Visibility(
                visible: showKbChip,
                child: Container(
                  margin: EdgeInsets.only(
                      top: isTablet ? 8 : 0),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: isAnonymous
                          ? Colors.black
                          : MyStyles.pupauTheme(!Get.isDarkMode).blue),
                  child: Row(
                    children: [
                      Text("KB",
                          style: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                              color: MyStyles.pupauTheme(!Get.isDarkMode).white)),
                      const SizedBox(width: 2),
                      Icon(Symbols.check,
                          size: isTablet ? 20 : 16,
                          color: MyStyles.pupauTheme(!Get.isDarkMode).white),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: showKbResources && hasKb,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: onTap,
                    child: Text(
                      Strings.references.tr,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w300,
                        color: isAnonymous ? Colors.white : null,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
