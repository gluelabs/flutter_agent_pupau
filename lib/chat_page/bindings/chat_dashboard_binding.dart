import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:get/get.dart';

class ChatDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ChatDashboardController>()) {
      Get.put<ChatDashboardController>(
        ChatDashboardController(),
        permanent: false,
      );
    }
  }
}

