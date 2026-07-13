import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/recording_bar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/stop_message_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/voice_mode_input.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/voice_recording_button.dart';
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
import 'package:material_symbols_icons/symbols.dart';

class ChatInputField extends GetView<PupauChatController> {
  const ChatInputField({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Obx(() {
      if (controller.hideInputBox.value) return const SizedBox();
      // Voice mode replaces the entire input area — no border, no FABs.
      if (controller.isVoiceMode.value) return const VoiceModeInput();
      bool isTablet = DeviceService.isTablet;
      bool isAnonymous = controller.isAnonymous;
      bool hideAudioRecordingButton = controller.hideAudioRecordingButton;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                final bool isEnabled = !controller.hasApiError.value;
                final bool sendIsActive = controller.sendIsActive();
                final bool hasText = controller.inputMessage.value
                    .trim()
                    .isNotEmpty;
                final bool isFocused =
                    controller.isMessageInputFieldFocused.value;
                final bool isRecording = controller.isRecording.value;
                final bool showVoiceModeToggle =
                    controller.isLiveVoiceAvailable;
                final bool isAdvanced = controller.isAdvanced();
                final bool showToolsToggle = isAdvanced;
                final int leftIconCount =
                    (showToolsToggle ? 1 : 0) + (showVoiceModeToggle ? 1 : 0);
                final double leftContentPadding = leftIconCount == 0
                    ? 16
                    : 16 +
                          leftIconCount * 38 -
                          (showToolsToggle && showVoiceModeToggle ? 12 : 0);
                final bool stopIsActive = controller.isStreaming.value;
                final BorderRadius borderRadius = BorderRadius.circular(8);
                return AbsorbPointer(
                  absorbing: !isEnabled,
                  child: Opacity(
                    opacity: isEnabled ? 1 : 0.5,
                    child: ClipRRect(
                      borderRadius: borderRadius,
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
                                  ).primary.withValues(alpha: 0.5)
                                : MyStyles.pupauTheme(
                                    !Get.isDarkMode,
                                  ).grey.withValues(alpha: 0.5),
                          ),
                        ),
                        child: isRecording
                            ? RecordingBar(
                                duration: controller.recordingDuration.value,
                                onCancel: () => controller.cancelRecording(),
                                onSend: () => controller.stopAndSendRecording(),
                                isAnonymous: isAnonymous,
                              )
                            : FocusScope(
                                child: Focus(
                                  onFocusChange: (value) => controller
                                      .setMessageInputFieldFocused(value),
                                  child: Stack(
                                    children: [
                                      MyMentionTagTextFormField(
                                        textCapitalization:
                                            TextCapitalization.sentences,
                                        cursorColor: isAnonymous
                                            ? Colors.black
                                            : null,
                                        focusNode: controller.keyboardFocusNode,
                                        controller:
                                            controller.inputMessageController,
                                        keyboardType: TextInputType.multiline,
                                        textInputAction:
                                            TextInputAction.newline,
                                        minLines: 1,
                                        maxLines: 12,
                                        style: TextStyle(
                                          fontSize: isTablet ? 16 : 14,
                                          color: isAnonymous
                                              ? AnonymousThemeColors.userText
                                              : null,
                                        ),
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.only(
                                            left: leftContentPadding,
                                            right: 15,
                                            top: 6,
                                            bottom: 6,
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
                                          suffixIcon: SizedBox(
                                            width: stopIsActive ? 82 : 0,
                                          ),
                                        ),
                                        onFieldSubmitted: sendIsActive
                                            ? (_) {
                                                controller.sendMessage(
                                                  controller
                                                      .inputMessageController
                                                      .getText,
                                                  false,
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
                                        mentionTagDecoration:
                                            MentionTagDecoration(
                                              mentionStart: ["@"],
                                              mentionTextStyle: TextStyle(
                                                color: MyStyles.pupauTheme(
                                                  !Get.isDarkMode,
                                                ).primary,
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                        onMention: controller.onMention,
                                      ),
                                      // Left-side icon buttons: tools toggle + voice mode toggle
                                      if (leftIconCount > 0)
                                        Positioned(
                                          left: 0,
                                          bottom: 0,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (showToolsToggle)
                                                IconButton(
                                                  onPressed: () => controller
                                                      .toggleToolsFab(),
                                                  icon: Icon(
                                                    controller
                                                            .toolsFabExpanded
                                                            .value
                                                        ? Symbols.remove
                                                        : Symbols.add,
                                                    size: 22,
                                                    color: isAnonymous
                                                        ? Colors.black
                                                        : MyStyles.pupauTheme(
                                                            !Get.isDarkMode,
                                                          ).primary,
                                                  ),
                                                ),
                                              if (showVoiceModeToggle)
                                                Transform.translate(
                                                  offset: Offset(
                                                    showToolsToggle ? -12 : 0,
                                                    0,
                                                  ),
                                                  child: IconButton(
                                                    onPressed: () => controller
                                                        .toggleVoiceMode(),
                                                    icon: Icon(
                                                      Symbols.voice_selection,
                                                      size: 22,
                                                      color: isAnonymous
                                                          ? Colors.black
                                                          : MyStyles.pupauTheme(
                                                              !Get.isDarkMode,
                                                            ).primary,
                                                    ),
                                                    tooltip: Strings
                                                        .voiceModeTooltip
                                                        .tr,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const StopMessageButton(),
                                            if (!hasText)
                                              if (!hideAudioRecordingButton)
                                                VoiceRecordingButton()
                                              else
                                                const SizedBox()
                                            else
                                              SendMessageButton(),
                                          ],
                                        ),
                                      ),
                                    ],
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
    });
  }
}
