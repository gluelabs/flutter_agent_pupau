import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_cache_service.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';

class PupauAssistantsController extends GetxController {
  RxList<Assistant> assistants = <Assistant>[].obs;

  Future<void> getAssistants() async {
    PupauChatController chatController = Get.find<PupauChatController>();
    bool isApiKey = chatController.pupauConfig?.apiKey != null;
    final String id = chatController.pupauConfig?.assistantId ?? "";
    final PupauAgentMode mode =
        chatController.pupauConfig?.agentMode ?? PupauAgentMode.assistant;
    if (isApiKey) {
      getSingleAssistant(id, mode);
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
    PupauAgentMode mode,
  ) async {
    final AssistantType type = mode == PupauAgentMode.marketplace
        ? AssistantType.marketplace
        : AssistantType.assistant;

    // Show whatever we already have (in-memory list, then the LRU cache)
    // immediately, with no network call.
    await _applyCachedAssistantImmediately(assistantId, type);

    // Always hit the network so server-side changes are picked up; what was
    // applied above is only a placeholder while this call is in flight.
    final Assistant? assistant = await AssistantService.getAssistant(
      assistantId,
      mode,
    );
    if (assistant == null) return;

    final int index = assistants.indexWhere(
      (a) => a.id == assistantId && a.type == type,
    );
    if (index >= 0) {
      assistants[index] = assistant;
    } else {
      assistants.add(assistant);
    }
    assistants.refresh();
    update();
  }

  /// Applies whatever assistant data is already available — the in-memory
  /// list first, then the [AssistantCacheService] LRU cache — to [assistants]
  /// immediately, with no network call, so the UI has something to show
  /// while [getSingleAssistant]'s fetch is in flight.
  Future<void> _applyCachedAssistantImmediately(
    String assistantId,
    AssistantType type,
  ) async {
    if (getAssistantById(assistantId, type) != null) return;
    final Assistant? cached = await AssistantCacheService.get(
      assistantId,
      type == AssistantType.marketplace
          ? PupauAgentMode.marketplace
          : PupauAgentMode.assistant,
    );
    if (cached == null) return;
    assistants.add(cached);
    assistants.refresh();
    update();
  }

  Assistant? getAssistantById(
    String assistantId,
    AssistantType assistantType,
  ) => assistants.firstWhereOrNull(
    (Assistant assistant) =>
        assistant.id == assistantId && assistant.type == assistantType,
  );
}
