import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/pupau_agent_chat.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_bindings.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:get/get.dart';

/// Utility class for programmatically interacting with the chat
class PupauChatUtils {
  /// Opens the chat page programmatically using the provided config
  ///
  /// If a conversation already exists, a new conversation will be created by resetting
  /// the chat state. This ensures a fresh conversation every time openChat is called.
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
    bool shouldResetChat = config.resetChatOnOpen;
    // Check if controller exists and has an existing conversation
    if (Get.isRegistered<PupauChatController>() && shouldResetChat) {
      final PupauChatController controller = Get.find<PupauChatController>();
      final bool hasExistingConversation =
          controller.conversation.value != null ||
          (controller.pupauConfig?.conversationId != null &&
              controller.pupauConfig!.conversationId!.trim().isNotEmpty);

      if (hasExistingConversation) {
        // Update config first
        await controller.openChatWithConfig(config);

        // Always create new conversation - reset chat state
        await resetChat();
        // After resetting, we still need to navigate to ensure chat page is open
      }
    }

    // Navigate to chat page if needed
    // Initialize binding with config (only registers, doesn't create)
    ChatBinding(config: config).dependencies();

    // Apply cached assistant immediately so first paint shows the right agent (no delay)
    if (Get.isRegistered<PupauChatController>()) {
      final PupauChatController controller = Get.find<PupauChatController>();
      controller.pupauConfig = config;
      controller.applyCachedAssistantIfAvailable();
    }

    // Navigate to chat page
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PupauAgentChat(config: config)),
    );
  }

  /// **Experimental.** Preloads the assistants list via [getAssistantsQuick] and
  /// precaches each assistant's avatar image. Call from a route that has a
  /// [BuildContext] (e.g. before showing a list/drawer of assistants).
  ///
  /// Auth is taken from (in order): [config], or a config built from
  /// [bearerToken], or the current [PupauChatController.pupauConfig] if
  /// already set. Pass [config] or [bearerToken] so the list API can
  /// authenticate. If only [bearerToken] is passed, a default [PupauConfig]
  /// is created (no assistant-specific info).
  ///
  /// - Registers bindings and applies the resolved config for API auth.
  /// - Fetches the quick list and updates [PupauAssistantsController.assistants].
  /// - Precaches medium-format avatar images so list avatars appear instantly.
  ///
  /// Returns the loaded list (or empty on failure).
  ///
  /// Example:
  /// ```dart
  /// final list = await PupauChatUtils.preloadAssistantsList(
  ///   context,
  ///   bearerToken: 'your-bearer-token',
  /// );
  /// // or with full config
  /// final list = await PupauChatUtils.preloadAssistantsList(
  ///   context,
  ///   config: myConfig,
  /// );
  /// ```
  static Future<List<Assistant>> preloadAssistantsList(
    BuildContext context, {
    PupauConfig? config,
    String? bearerToken,
  }) async {
    PupauConfig? effectiveConfig = config;
    if (effectiveConfig == null &&
        bearerToken != null &&
        bearerToken.trim().isNotEmpty) {
      final PupauChatController? controller = Get.isRegistered<PupauChatController>()
          ? Get.find<PupauChatController>()
          : null;
      final PupauConfig? existing = controller?.pupauConfig;
      final String? cachedAssistantId = controller?.assistant.value?.id;
      final String resolvedAssistantId = (existing?.assistantId.trim().isNotEmpty == true)
          ? existing!.assistantId
          : (cachedAssistantId?.trim().isNotEmpty == true ? cachedAssistantId! : "");
      effectiveConfig = PupauConfig.createWithToken(
        bearerToken: bearerToken.trim(),
        assistantId: resolvedAssistantId,
        apiUrl: existing?.apiUrl,
        language: existing?.language ?? PupauLanguage.en,
        hideInputBox: existing?.hideInputBox ?? false,
        showNerdStats: existing?.showNerdStats ?? false,
        hideAudioRecordingButton: existing?.hideAudioRecordingButton ?? false,
        resetChatOnOpen: existing?.resetChatOnOpen ?? true,
      );
    }
    if (effectiveConfig == null && Get.isRegistered<PupauChatController>()) {
      effectiveConfig = Get.find<PupauChatController>().pupauConfig;
    }

    ChatBinding(config: effectiveConfig).dependencies();

    if (effectiveConfig != null && Get.isRegistered<PupauChatController>()) {
      final controller = Get.find<PupauChatController>();
      controller.pupauConfig = effectiveConfig;
      ApiUrls.setApiUrlOverride(effectiveConfig.apiUrl);
    }

    List<Assistant> list = await AssistantService.getAssistantsQuick();

    if (list.isNotEmpty && Get.isRegistered<PupauAssistantsController>()) {
      final assistantsController = Get.find<PupauAssistantsController>();
      assistantsController.assistants.value = list;
      assistantsController.assistants.refresh();
      assistantsController.update();
    }

    if (!context.mounted) return list;

    for (final assistant in list) {
      if (assistant.imageUuid.isEmpty) continue;
      final String imageUrl = AssistantService.getAssistantImageUrl(
        assistant.id,
        assistant.imageUuid,
        assistant.type == AssistantType.marketplace,
        ImageFormat.medium,
      );
      try {
        await precacheImage(
          CachedNetworkImageProvider(imageUrl, errorListener: (error) {}),
          context,
          onError: (exception, stackTrace) {},
        );
      } catch (_) {}
      if (!context.mounted) return list;
    }

    return list;
  }

  /// Resets the chat state of the current chat with the current config
  /// This will reset the chat state and emit a reset conversation event
  /// Example:
  /// ```dart
  /// PupauChatUtils.resetChat();
  /// ```
  static Future<void> resetChat() async {
    Get.find<PupauChatController>().resetChatState();
  }

  /// Loads a conversation by its id in the current chat with the current config
  /// Resets the whole chat state first, then loads the conversation if valid
  /// This will load a conversation and emit a conversation changed event
  ///
  /// Example:
  /// ```dart
  /// PupauChatUtils.loadConversation('123');
  /// ```
  static Future<void> loadConversation(String conversationId) async {
    final PupauChatController controller = Get.find<PupauChatController>();

    // Reset the whole chat state first
    controller.resetChatState();

    // Then load the conversation (it will validate and load if valid)
    await controller.loadConversation(conversationId);
  }

  /// Starts an anonymous chat using the last used config
  /// Takes the existing config and sets isAnonymous to true, then resets chat and updates UI
  /// Meant to be used while inside a chat page, with a working config
  /// Example:
  /// ```dart
  /// PupauChatUtils.startAnonymousChat();
  /// ```
  static Future<void> startAnonymousChat() async {
    final PupauChatController controller = Get.find<PupauChatController>();
    final PupauConfig? currentConfig = controller.pupauConfig;

    if (currentConfig == null) {
      throw Exception('No config found. Please open chat first.');
    }

    // Create a new config with isAnonymous set to true using copyWith
    final PupauConfig anonymousConfig = currentConfig.copyWith(
      conversationId: null, // Clear conversationId for anonymous chat
      isAnonymous: true,
    );

    // Reset chat state
    controller.resetChatState();

    // Update config and refresh UI
    await controller.openChatWithConfig(anonymousConfig);
  }

  /// Toggles the isAnonymous value of the current config
  /// Resets chat state and updates UI after toggling
  /// Example:
  /// ```dart
  /// await PupauChatUtils.toggleAnonymousMode();
  /// ```
  static Future<void> toggleAnonymousMode() async {
    final PupauChatController controller = Get.find<PupauChatController>();
    final PupauConfig? currentConfig = controller.pupauConfig;

    if (currentConfig == null) {
      throw Exception('No config found. Please open chat first.');
    }

    // Toggle isAnonymous value using copyWith
    final toggledConfig = currentConfig.copyWith(
      conversationId: null,
      isAnonymous: !currentConfig.isAnonymous,
    );

    // Reset chat state
    controller.resetChatState();

    // Update config and refresh UI
    await controller.openChatWithConfig(toggledConfig);
  }

  /// Starts a new conversation. If [isCurrentlyAnonymous] is true, toggles to
  /// non-anonymous mode first (then resets). Otherwise just resets the chat.
  /// Use this from drawer "New conversation" so toggle + reset run in order with proper await.
  ///
  /// Example:
  /// ```dart
  /// DrawerItem(
  ///   text: Strings.newConversation.tr,
  ///   onTap: () async {
  ///     await PupauChatUtils.startNewConversation(
  ///       isCurrentlyAnonymous: PupauPluginService.isCurrentConversationAnonymous,
  ///     );
  ///     Get.back();
  ///   },
  /// )
  /// ```
  static Future<void> startNewConversation({
    required bool isCurrentlyAnonymous,
  }) async {
    isCurrentlyAnonymous
        ? await toggleAnonymousMode() // already resets + updates config; do not call resetChat() after
        : await resetChat();
  }

  /// Exits anonymous/incognito mode and starts a new conversation.
  /// This is a specific method for when user wants to create a new conversation
  /// while currently in anonymous mode. It ensures the mode is toggled OFF
  /// and a fresh conversation is started.
  ///
  /// Example:
  /// ```dart
  /// DrawerItem(
  ///   text: Strings.newConversation.tr,
  ///   onTap: () async {
  ///     await PupauChatUtils.exitAnonymousAndStartNewConversation();
  ///     Get.back();
  ///   },
  /// )
  /// ```
  static Future<void> exitAnonymousAndStartNewConversation() async {
    final PupauChatController controller = Get.find<PupauChatController>();
    final PupauConfig? currentConfig = controller.pupauConfig;

    if (currentConfig == null) {
      throw Exception('No config found. Please open chat first.');
    }

    // If not in anonymous mode, just reset
    if (!currentConfig.isAnonymous) {
      await resetChat();
      return;
    }

    // Create a new config with isAnonymous set to false and conversationId cleared
    final nonAnonymousConfig = currentConfig.copyWith(
      conversationId: null, // Clear conversationId for new conversation
      isAnonymous: false, // Exit anonymous mode
    );

    // Update config and re-initialize with non-anonymous config
    // openChatWithConfig will handle resetting state when it detects anonymousChanged
    // This ensures the UI updates and a fresh conversation starts
    await controller.openChatWithConfig(nonAnonymousConfig);
  }

  /// Sets the visibility of nerds stats (token/credit statistics) in the chat.
  /// This allows programmatic control over whether the stats are displayed.
  ///
  /// Example:
  /// ```dart
  /// // Show nerds stats
  /// PupauChatUtils.setNerdStats(true);
  ///
  /// // Hide nerds stats
  /// PupauChatUtils.setNerdStats(false);
  /// ```
  static void setNerdStats(bool show) {
    final PupauChatController controller = Get.find<PupauChatController>();
    controller.setNerdStats(show);
  }

  /// Updates the auth token on the currently open chat and unblocks any API
  /// calls that were waiting for a refreshed token after receiving 401.
  ///
  /// This is designed for the host app flow:
  /// - plugin emits `UpdateConversationType.authError`
  /// - host refreshes token
  /// - host calls this method with the new bearer token
  static Future<void> updateAuthToken(String bearerToken) async {
    final PupauChatController controller = Get.find<PupauChatController>();
    final PupauConfig? currentConfig = controller.pupauConfig;

    if (currentConfig == null) {
      throw Exception('No config found. Please open chat first.');
    }

    final String resolvedAssistantId = controller.assistant.value?.id
            .trim()
            .isNotEmpty ==
        true
        ? controller.assistant.value!.id
        : currentConfig.assistantId;

    final PupauConfig newConfig = PupauConfig.createWithToken(
      bearerToken: bearerToken,
      assistantId: resolvedAssistantId,
      apiUrl: currentConfig.apiUrl,
      isMarketplace: currentConfig.isMarketplace,
      conversationId: currentConfig.conversationId,
      isAnonymous: currentConfig.isAnonymous,
      language: currentConfig.language,
      googleMapsApiKey: currentConfig.googleMapsApiKey,
      hideInputBox: currentConfig.hideInputBox,
      widgetMode: currentConfig.widgetMode,
      sizedConfig: currentConfig.sizedConfig,
      floatingConfig: currentConfig.floatingConfig,
      showNerdStats: currentConfig.showNerdStats,
      hideAudioRecordingButton: currentConfig.hideAudioRecordingButton,
      customProperties: currentConfig.customProperties,
      conversationStarters: currentConfig.conversationStarters,
      appBarConfig: currentConfig.appBarConfig,
      drawerConfig: currentConfig.drawerConfig,
      resetChatOnOpen: currentConfig.resetChatOnOpen,
      initialWelcomeMessage: currentConfig.initialWelcomeMessage,
    );

    controller.pupauConfig = newConfig;
    ApiUrls.setApiUrlOverride(newConfig.apiUrl);
    ApiService.notifyAuthTokenUpdated();
    controller.update();
  }
  
  /// Reloads the current assistant from the API using the current config.
  /// Use when the user has changed configuration (e.g. assistantId or API settings)
  /// and you want the chat to reflect the updated assistant in real time without
  /// reopening the chat.
  ///
  /// Example:
  /// ```dart
  /// // After updating config on the controller or elsewhere:
  /// await PupauChatUtils.reloadCurrentAssistant();
  /// ```
  static Future<void> reloadCurrentAssistant() async =>
      await Get.find<PupauChatController>().reloadCurrentAssistant();

  /// Sets the visibility of the input box in the chat.
  /// When set to true, the input field and related tools will be hidden.
  /// When set to false, the input field and tools will be shown.
  /// Updates the config and applies changes seamlessly using GetX reactivity.
  ///
  /// Example:
  /// ```dart
  /// // Hide the input box
  /// await PupauChatUtils.setHideInputBox(true);
  ///
  /// // Show the input box
  /// await PupauChatUtils.setHideInputBox(false);
  /// ```
  static Future<void> setHideInputBox(bool hide) async {
    final PupauChatController controller = Get.find<PupauChatController>();
    final PupauConfig? currentConfig = controller.pupauConfig;

    if (currentConfig == null) {
      throw Exception('No config found. Please open chat first.');
    }

    // Update config with hideInputBox value using copyWith
    final updatedConfig = currentConfig.copyWith(hideInputBox: hide);

    // Update config seamlessly - GetX reactivity will handle UI updates
    controller.pupauConfig = updatedConfig;
    controller.hideInputBox.value = hide;
  }
}
