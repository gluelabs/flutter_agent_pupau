import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/conversation_starters_list.dart';
import 'package:get/get.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/my_mention_tag_text_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/send_message_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/taggable_assistants_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/tagged_assistants_list.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ChatInputField extends GetView<ChatController> {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    bool hideInputBox = controller.hideInputBox;
    if (hideInputBox) return const SizedBox();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ConversationStartersList(),
        const TaggedAssistantsList(),
        const TaggableAssistantsList(),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: isTablet ? 12 : 4,
            ),
            child: Obx(() {
              bool isEnabled = !controller.hasApiError.value;
              bool sendIsActive = controller.sendIsActive();
              bool isFocused = controller.isMessageInputFieldFocused.value;
              bool isAdvanced = controller.isAdvanced();
              bool isMultiline =
                  controller.messageInputFieldHeight.value >
                  (isTablet ? 74 : 58);
              BorderRadius borderRadius = !isAdvanced
                  ? BorderRadius.circular(8)
                  : isMultiline
                  ? BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.zero,
                    )
                  : BorderRadius.horizontal(right: Radius.circular(8));
              return AbsorbPointer(
                absorbing: !isEnabled,
                child: Opacity(
                  opacity: isEnabled ? 1 : 0.5,
                  child: ClipRRect(
                    borderRadius: borderRadius,
                    child: Padding(
                      padding: !isAdvanced
                          ? EdgeInsets.zero
                          : const EdgeInsets.only(left: 44),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: borderRadius,
                          color: isAnonymous
                              ? AnonymousThemeColors.userBubble
                              : MyStyles.pupauTheme(!Get.isDarkMode).white,
                          border: Border.all(
                            color: isAnonymous
                                ? Colors.transparent
                                : isFocused
                                ? MyStyles.pupauTheme(
                                    !Get.isDarkMode,
                                  ).lilacPressed
                                : MyStyles.pupauTheme(
                                    !Get.isDarkMode,
                                  ).lilacHover,
                          ),
                        ),
                        child: FocusScope(
                          child: Focus(
                            onFocusChange: (value) =>
                                controller.setMessageInputFieldFocused(value),
                            child: Stack(
                              children: [
                                MyMentionTagTextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  cursorColor: isAnonymous
                                      ? Colors.black
                                      : null,
                                  focusNode: controller.keyboardFocusNode,
                                  controller: controller.inputMessageController,
                                  keyboardType: TextInputType.multiline,
                                  textInputAction: TextInputAction.newline,
                                  minLines: 1,
                                  maxLines: 12,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: isAnonymous
                                        ? AnonymousThemeColors.userText
                                        : null,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 6,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    hintText: "${Strings.message.tr}...",
                                    hintStyle: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      color: isAnonymous
                                          ? AnonymousThemeColors.userText
                                          : null,
                                    ),
                                    suffixIcon: const SizedBox(),
                                  ),
                                  onFieldSubmitted: sendIsActive
                                      ? (_) {
                                          controller.sendMessage(
                                            controller
                                                .inputMessageController
                                                .getText,
                                            false,
                                          );
                                          controller.getMessageInputFieldHeight(
                                            context,
                                          );
                                        }
                                      : null,
                                  onChanged: (value) {
                                    controller.getMessageInputFieldHeight(
                                      context,
                                    );
                                    controller.messages.refresh();
                                    controller.inputMessage.value = value;
                                    controller.update();
                                  },
                                  mentionTagDecoration: MentionTagDecoration(
                                    mentionStart: ["@"],
                                    mentionTextStyle: TextStyle(
                                      color: MyStyles.pupauTheme(
                                        !Get.isDarkMode,
                                      ).accent,
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onMention: controller.onMention,
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: const SendMessageButton(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
