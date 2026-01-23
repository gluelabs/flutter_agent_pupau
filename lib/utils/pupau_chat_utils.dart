import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/pupau_agent_chat.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_bindings.dart';
import 'package:get/get.dart';

/// Utility class for programmatically interacting with the chat
class PupauChatUtils {
  /// Opens the chat page programmatically using the provided config
  /// 
  /// Example:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => PupauChatUtils.openChat(
  ///     context,
  ///     PupauConfig.createWithApiKey(
  ///       apiKey: 'your-api-key',
  ///     ),
  ///   ),
  ///   child: Text('Open Chat'),
  /// )
  /// ```
  static Future<void> openChat(BuildContext context, PupauConfig config) async {    
    // Initialize binding with config (only registers, doesn't create)
    ChatBinding(config: config).dependencies();
    
    // DO NOT call Get.find() here - it will trigger lazy creation
    // The controller will be created and initialized in PupauAgentChat.initState
    // This prevents duplicate initializations
    
    // Navigate to chat page
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PupauAgentChat(
          config: config,
        ),
      ),
    );
  }
  
  /// Resets the chat state of the current chat with the current config
  /// This will reset the chat state and emit a reset conversation event
  /// Example:
  /// ```dart
  /// PupauChatUtils.resetChat();
  /// ```
  static Future<void> resetChat() async {
    Get.find<ChatController>().resetChatState(isManualReset: true);
  }

  /// Loads a conversation by its id in the current chat with the current config
  /// This will load a conversation and emit a conversation changed event
  /// Example:
  /// ```dart
  /// PupauChatUtils.loadConversation('123');
  /// ```
  static Future<void> loadConversation(String conversationId) async {
    Get.find<ChatController>().loadConversation(conversationId, isManualLoad: true);
  }
}

