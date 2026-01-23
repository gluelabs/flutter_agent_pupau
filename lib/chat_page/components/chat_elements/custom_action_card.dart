import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/custom_action_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class CustomActionCard extends GetView<ChatController> {
  const CustomActionCard({super.key, required this.customAction});

  final CustomAction customAction;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Obx(() {
        AssistantsController assistantsController =
            Get.find<AssistantsController>();
        bool canSendPrompt =
            !controller.stopIsActive() && customAction.setting?.prompt != null;
        String? assistantId = customAction.setting?.assistantId;
        AssistantType? assistantType =
            customAction.setting?.assistantType ??
            (assistantId != null ? AssistantType.assistant : null);
        bool hasAssistantInfo = assistantId != null && assistantType != null;
        Assistant? assistant = hasAssistantInfo
            ? assistantsController.getAssistantById(assistantId, assistantType)
            : null;
        String prompt = assistant != null
            ? "${TagService.getAssistantTag(assistant)} ${customAction.setting?.prompt ?? ""}"
            : customAction.setting?.prompt ?? "";
        return Opacity(
          opacity: canSendPrompt ? 1 : 0.5,
          child: AbsorbPointer(
            absorbing: !canSendPrompt,
            child: Material(
              elevation: 0,
              color: MyStyles.pupauTheme(!Get.isDarkMode).white,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => canSendPrompt
                    ? {
                        controller.sendMessage(prompt, false),
                        Navigator.pop(context),
                      }
                    : null,
                child: Container(
                  width: DeviceService.width,
                  padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: MyStyles.pupauTheme(!Get.isDarkMode).lilacHover,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        customAction.icon,
                        size: isTablet ? 26 : 24,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                customAction.userLabel,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: MyStyles.pupauTheme(
                                    !Get.isDarkMode,
                                  ).darkBlue,
                                ),
                              ),
                              if (customAction.userDescription
                                  .trim()
                                  .isNotEmpty)
                                Text(
                                  customAction.userDescription,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    color: Get.theme.textTheme.bodyMedium?.color
                                        ?.withValues(alpha: 0.65),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
