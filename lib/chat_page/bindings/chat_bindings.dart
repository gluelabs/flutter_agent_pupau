import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/browser_inspector_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/tool_ask_user_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  final PupauConfig? config;

  ChatBinding({this.config});

  @override
  void dependencies() {
    // Simply ensure controllers exist - no deletion or reset here
    // Reset will happen when chat is actually opened (in PupauAgentChat or PupauChatUtils)
    // IMPORTANT: Use Get.put instead of lazyPut for PupauChatController to prevent multiple creations
    // when GetView accesses it multiple times
    if (!Get.isRegistered<PupauChatController>()) {
      Get.put<PupauChatController>(
        PupauChatController(config: config),
        permanent: false,
      );
    }
    // Note: If controller already exists, config will be updated when openChatWithConfig is called
    if (!Get.isRegistered<PupauAttachmentsController>()) {
      Get.lazyPut<PupauAttachmentsController>(
        () => PupauAttachmentsController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PupauBrowserInspectorController>()) {
      Get.lazyPut<PupauBrowserInspectorController>(
        () => PupauBrowserInspectorController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PupauToolAskUserController>()) {
      Get.lazyPut<PupauToolAskUserController>(
        () => PupauToolAskUserController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<PupauAssistantsController>()) {
      Get.lazyPut<PupauAssistantsController>(
        () => PupauAssistantsController(),
        fenix: true,
      );
    }
  }
}
