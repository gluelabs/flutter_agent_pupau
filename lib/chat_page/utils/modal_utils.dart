import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

/// Helper function to get safe context for modals
/// This ensures modals work correctly when the plugin is used in other projects
BuildContext? getSafeModalContext() {
  try {
    ChatController chatController = Get.find();
    return chatController.safeContext;
  } catch (e) {
    return null;
  }
}



