import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_chip.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';

class TaggedAssistantsList extends GetView<ChatController> {
  const TaggedAssistantsList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      List<Assistant> taggedAssistants = controller.taggedAssistants;
      int length = taggedAssistants.length;
      bool isTagging = controller.filteredAssistants.isNotEmpty;
      return length > 0 && !isTagging
          ? Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: SizedBox(
                height: isTablet ? 42 : 38,
                width: DeviceService.width,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: taggedAssistants
                          .map((assistant) => AssistantChip(
                              assistant: assistant,
                              isAnonymous: controller.isAnonymous))
                          .toList(),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox();
    });
  }
}
