import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class ToolAskUserController extends GetxController {
  ToolUseMessage? toolUseMessage;
  ToolUseAskUserData? askUserData;
  RxList<AskUserChoice> selectedOptions = <AskUserChoice>[].obs;
  RxString customOptionText = "".obs;
  TextEditingController customOptionController = TextEditingController();

  void setAskUserData(ToolUseMessage? data) {
    toolUseMessage = data;
    askUserData = data?.askUserData;
    update();
  }

  void selectOption(AskUserChoice option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
    selectedOptions.refresh();
    update();
  }

  void setCustomOptionText(String text) {
    customOptionText.value = text;
    update();
  }

  bool canSubmit() {
    if (askUserData?.choiceType == AskUserChoiceType.choice) {
      return selectedOptions.isNotEmpty;
    }
    if (askUserData?.choiceType == AskUserChoiceType.text) {
      return customOptionText.value.trim() != "";
    }
    return true;
  }

  bool isSuggested(AskUserChoice option) {
    if (askUserData?.suggestedChoiceIndex == null) return false;
    return askUserData?.suggestedChoiceIndex == option.index;
  }

  void submitAnswer() {
    if (canSubmit()) {
      Get.find<ChatController>().sendToolAnswer(toolUseMessage?.messageId ?? "",
          selectedOptions, customOptionText.value);
    }
  }
}
