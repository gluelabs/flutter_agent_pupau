import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/tool_ask_user_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_input_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/ask_user_option.dart';

class MessageAskUser extends StatelessWidget {
  const MessageAskUser({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    ToolUseAskUserData? askUserData = toolUseMessage?.askUserData;
    String question = askUserData?.question ?? "";
    AskUserChoiceType choiceType =
        askUserData?.choiceType ?? AskUserChoiceType.choice;
    bool hasSubmit = choiceType == AskUserChoiceType.text ||
        (choiceType == AskUserChoiceType.choice &&
            (askUserData?.isMultiselect ?? false));
    ToolAskUserController controller =
        Get.put(ToolAskUserController(), tag: toolUseMessage?.id);
    ChatController chatController = Get.find();
    controller.setAskUserData(toolUseMessage);
    return Obx(() {
      bool canSubmit = controller.canSubmit();
      bool isMultiselect = askUserData?.isMultiselect ?? false;
      bool isActive =
          chatController.messages.first.id == toolUseMessage?.messageId;
      List<AskUserChoice> selectedOptions = controller.selectedOptions;
      return AbsorbPointer(
        absorbing: !isActive,
        child: Opacity(
          opacity: isActive ? 1.0 : 0.3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Text(
                question,
                style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: isAnonymous ? Colors.white : null),
              ),
              SizedBox(height: 16),
              if (choiceType == AskUserChoiceType.choice)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: askUserData?.choices
                          .map((option) => AskUserOption(
                              option: option.choice,
                              isSelected: selectedOptions.contains(option),
                              isSuggested: controller.isSuggested(option),
                              isAnonymous: isAnonymous,
                              onTap: () {
                                if (isMultiselect) {
                                  controller.selectOption(option);
                                } else {
                                  controller.selectOption(option);
                                  controller.submitAnswer();
                                }
                              }))
                          .toList() ??
                      [],
                ),
              if (choiceType == AskUserChoiceType.text)
                CustomInputField(
                  textController: controller.customOptionController,
                  hint: Strings.typeYourAnswer.tr,
                  topPadding: 0,
                  onChange: (String text) =>
                      controller.setCustomOptionText(text),
                ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  askUserData?.suggestedChoiceIndex != null &&
                          choiceType == AskUserChoiceType.choice
                      ? Padding(
                        padding: EdgeInsets.only(top: 8, bottom: hasSubmit ? 0 : 4),
                        child: Text("* ${Strings.suggestedChoice.tr}",
                            style: TextStyle(color: isAnonymous ? Colors.white : null, fontSize: 12)),
                      )
                      : SizedBox(),
                  if (hasSubmit)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: CustomButton(
                          text: Strings.submit.tr,
                          isEnabled: canSubmit,
                          onPressed: () => controller.submitAnswer()),
                    ),
                ],
              )
            ],
          ),
        ),
      );
    });
  }
}
