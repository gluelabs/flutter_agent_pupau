import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/my_mention_tag_text_editing_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/marketplace_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class TaggableAssistantsList extends GetView<ChatController> {
  const TaggableAssistantsList({super.key});

  @override
  Widget build(BuildContext context) {
    MyMentionTagTextEditingController textController = controller.inputMessageController;
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      // ignore: invalid_use_of_protected_member
      List<Assistant> filteredAssistants = controller.filteredAssistants.value;
      bool isAnonymous = controller.isAnonymous;
      Color backgroundColor = isAnonymous
          ? AnonymousThemeColors.background
          : MyStyles.pupauTheme(!Get.isDarkMode).white;
      return filteredAssistants.isEmpty
          ? const SizedBox()
          : Container(
              transform: Matrix4.translationValues(0, 20, 0),
              constraints: BoxConstraints(maxHeight: DeviceService.height * 0.35),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12))),
              child: ListView.builder(
                  itemCount: filteredAssistants.length,
                  reverse: true,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    Assistant assistant = filteredAssistants[index];
                    bool isFirst = index == filteredAssistants.length - 1;
                    bool isLast = index == 0;
                    bool isAlreadyTagged =
                        controller.inputMessageController.mentions.contains(assistant);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        isAlreadyTagged
                            ? const SizedBox()
                            : InkWell(
                                onTap: () {
                                  textController.addMention(
                                    label: assistant.name,
                                    data: assistant,
                                  );
                                  controller.onMentionTap();
                                },
                                child: Container(
                                    width: DeviceService.width,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6, horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: backgroundColor,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: isFirst ? 6 : 0,
                                              bottom: isLast ? 6 : 0),
                                          child: Row(
                                            children: [
                                              AssistantAvatar(
                                                  assistantId: assistant.id,
                                                  imageUuid:
                                                      assistant.imageUuid,
                                                  isMarketplaceUrl: assistant
                                                          .type ==
                                                      AssistantType.marketplace,
                                                  radius: 14,
                                                  format: ImageFormat.low),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      assistant.name,
                                                      maxLines: 2,
                                                      style: TextStyle(
                                                          fontSize: isTablet
                                                              ? 16
                                                              : 14,
                                                          color: isAnonymous
                                                              ? AnonymousThemeColors
                                                                  .assistantText
                                                              : null),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    if (assistant.type ==
                                                        AssistantType
                                                            .marketplace)
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8),
                                                          child: MarketplaceIcon(
                                                              color: isAnonymous
                                                                  ? Colors.white
                                                                  : MyStyles.getTextTheme(
                                                                          isLightTheme:
                                                                              !Get.isDarkMode)
                                                                      .bodyMedium!
                                                                      .color))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (!isLast)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Container(
                                                width: DeviceService.width,
                                                height: 1,
                                                color: isAnonymous
                                                    ? Colors.black
                                                    : MyStyles.pupauTheme(
                                                            !Get.isDarkMode)
                                                        .lilacHover),
                                          )
                                      ],
                                    )),
                              ),
                        if (isLast)
                          Container(
                            width: DeviceService.width,
                            height: 20,
                            color: backgroundColor,
                          )
                      ],
                    );
                  }),
            );
    });
  }
}
