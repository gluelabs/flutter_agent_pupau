import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';

class PupauAssistantsController extends GetxController {
  RxList<Assistant> assistants = <Assistant>[].obs;

  Future<void> getAssistants() async {
    PupauChatController chatController = Get.find<PupauChatController>();
    bool isApiKey = chatController.pupauConfig?.apiKey != null;
    final String id = chatController.pupauConfig?.assistantId ?? "";
    final bool isMarketplace =
        chatController.pupauConfig?.isMarketplace ?? false;
    if (isApiKey) {
      getSingleAssistant(id, isMarketplace);
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

  Future<void> getSingleAssistant(
    String assistantId,
    bool isMarketplace,
  ) async {
    final AssistantType type = isMarketplace
        ? AssistantType.marketplace
        : AssistantType.assistant;
    final Assistant? existing = getAssistantById(assistantId, type);

    // When not forcing refresh: skip if we already have this assistant with non-empty welcome
    if (existing != null && existing.welcomeMessage.trim().isNotEmpty) {
      // ignore: avoid_print
      return;
    }
    Assistant? assistant = await AssistantService.getAssistant(
      assistantId,
      isMarketplace,
    );
    if (assistant == null) return;

    if (existing != null) {
      final int index = assistants.indexWhere(
        (a) => a.id == assistantId && a.type == type,
      );
      if (index >= 0) {
        assistants[index] = assistant;
        assistants.refresh();
        update();
      }
    } else {
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
