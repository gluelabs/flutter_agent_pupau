import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';

class AssistantsController extends GetxController {
  RxList<Assistant> assistants = <Assistant>[].obs;

  Future<void> getAssistants() async {
    ChatController chatController = Get.find<ChatController>();
    bool isApiKey = chatController.pupauConfig?.apiKey != null;
    if (isApiKey) {
      getSingleAssistant(chatController.pupauConfig?.assistantId ?? "");
      return;
    }
    List<Assistant> assistantsList =
        await AssistantService.getAssistantsQuick();
    if (assistantsList.isNotEmpty) {
      assistants.value = assistantsList;
      assistants.refresh();
      update();
    }
  }

  Future<void> getSingleAssistant(String assistantId) async {
    if (assistants.firstWhereOrNull(
          (Assistant assistant) => assistant.id == assistantId,
        ) !=
        null) {
      return;
    }
    Assistant? assistant = await AssistantService.getAssistant(
      assistantId,
      false,
    );
    if (assistant != null) {
      assistants.add(assistant);
      assistants.refresh();
      update();
    }
  }

  Assistant? getAssistantById(
    String assistantId,
    AssistantType assistantType,
  ) => assistants.firstWhereOrNull(
    (Assistant assistant) =>
        assistant.id == assistantId && assistant.type == assistantType,
  );
}
