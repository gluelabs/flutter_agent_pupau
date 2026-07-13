import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_image_full.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/custom_actions_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_tool_availability.dart';
import 'package:flutter_agent_pupau/chat_page/utils/message_grouping_utils.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/models/memory_reference_model.dart';
import 'package:flutter_agent_pupau/models/memory_always_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/audio_recording_service.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';
import 'package:flutter_agent_pupau/services/voice_playback_service.dart';
import 'package:flutter_agent_pupau/services/voice_sound_cue_service.dart';
import 'package:flutter_agent_pupau/services/message_service.dart';
import 'package:flutter_agent_pupau/services/settings_service.dart';
import 'package:flutter_agent_pupau/services/sse_service.dart';
import 'package:flutter_agent_pupau/services/inline_thinking_message_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_thinking_data.dart';
import 'package:flutter_agent_pupau/services/tool_args_delta_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:flutter_agent_pupau/utils/settings.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/my_mention_tag_text_editing_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/edit_message_dialog.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/fork_conversation_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_notifier.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/attachment_trimming_dialog.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/memory_references_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_basic_dialog.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/loading_message_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/setting_model.dart';
import 'package:flutter_agent_pupau/models/voice_session_model.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_args_delta_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_heartbeat_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_partial_result_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_pending_data.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_ask_user_service.dart';
import 'package:flutter_agent_pupau/services/attachment_tool_label_service.dart';
import 'package:flutter_agent_pupau/services/grounding_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/services/user_service.dart';
import 'package:flutter_agent_pupau/services/tts_service.dart';
import 'package:flutter_agent_pupau/services/ui_tool_service.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_agent_pupau/services/skills_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/localization_service.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/chat_page/bindings/chat_dashboard_binding.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/chat_page/pages/chat_dashboard_page_view.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class PupauChatController extends GetxController {
  PupauChatController({PupauConfig? config}) : pupauConfig = config {
    ApiUrls.setApiUrlOverride(config?.apiUrl);
  }
  PupauConfig? pupauConfig;
  String? _cachedAssistantId;

  String get assistantId {
    final String? currentId = pupauConfig?.assistantId;
    if (currentId != null && currentId.trim().isNotEmpty) return currentId;
    return _cachedAssistantId ?? "";
  }

  bool get isMarketplace => pupauConfig?.isMarketplace ?? false;
  bool get isAnonymous => pupauConfig?.isAnonymous ?? false;
  bool get hideAudioRecordingButton =>
      pupauConfig?.hideAudioRecordingButton ?? false;
  bool get isLiveVoiceAvailable =>
      (assistant.value?.voiceEnabled ?? false) &&
      (assistant.value?.sttAvailable ?? false) &&
      (assistant.value?.ttsAvailable ?? false);
  WidgetMode get widgetMode => pupauConfig?.widgetMode ?? WidgetMode.full;
  RxList<String> conversationStarters = <String>[].obs;

  // Store the BuildContext from the main widget for modal usage
  BuildContext? _modalContext;
  // Store the Scaffold context for drawer operations
  BuildContext? _scaffoldContext;

  void setModalContext(BuildContext context) {
    _modalContext = context;
  }

  void setScaffoldContext(BuildContext context) {
    _scaffoldContext = context;
  }

  // Get safe context for modals - prefer stored context, fallback to Get.context
  BuildContext? get safeContext => _modalContext ?? Get.context;

  // Get scaffold context - prefer stored scaffold context, fallback to modal context
  BuildContext? get scaffoldContext =>
      _scaffoldContext ?? _modalContext ?? Get.context;

  /// Safely opens the drawer using scaffoldKey or context
  void openDrawer() {
    final scaffoldKey = pupauConfig?.drawerConfig?.scaffoldKey;
    if (scaffoldKey?.currentState != null) {
      scaffoldKey!.currentState!.openDrawer();
      return;
    }
    // Fallback to using scaffold context if scaffoldKey is not available
    BuildContext? context = scaffoldContext;
    if (context != null) {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        scaffoldState.openDrawer();
      }
    }
  }

  /// Safely opens the end drawer using scaffoldKey or context
  void openEndDrawer() {
    final scaffoldKey = pupauConfig?.drawerConfig?.scaffoldKey;
    if (scaffoldKey?.currentState != null) {
      scaffoldKey!.currentState!.openEndDrawer();
      return;
    }
    // Fallback to using scaffold context if scaffoldKey is not available
    BuildContext? context = scaffoldContext;
    if (context != null) {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        scaffoldState.openEndDrawer();
      }
    }
  }

  /// Safely closes the drawer using scaffoldKey or context
  void closeDrawer() {
    final scaffoldKey = pupauConfig?.drawerConfig?.scaffoldKey;
    if (scaffoldKey?.currentState != null) {
      scaffoldKey!.currentState!.closeDrawer();
      return;
    }
    // Fallback to using scaffold context if scaffoldKey is not available
    BuildContext? context = scaffoldContext;
    if (context != null) {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        scaffoldState.closeDrawer();
      }
    }
  }

  /// Safely closes the end drawer using scaffoldKey or context
  void closeEndDrawer() {
    final scaffoldKey = pupauConfig?.drawerConfig?.scaffoldKey;
    if (scaffoldKey?.currentState != null) {
      scaffoldKey!.currentState!.closeEndDrawer();
      return;
    }
    // Fallback to using scaffold context if scaffoldKey is not available
    BuildContext? context = scaffoldContext;
    if (context != null) {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        scaffoldState.closeEndDrawer();
      }
    }
  }

  /// Tracks an in-shell dashboard route (sized/floating) for [PopScope.canPop].
  /// The nested [Navigator] does not notify [Obx] when its stack changes.
  final RxBool isEmbeddedChatDashboardOpen = false.obs;

  /// In-view navigator for sized/floating chat; used to push the dashboard route.
  final GlobalKey<NavigatorState> chatShellNavigatorKey =
      GlobalKey<NavigatorState>();

  void openChatDashboard() {
    if (widgetMode == WidgetMode.full) {
      Get.to(
        () => const ChatDashboardPageView(),
        binding: ChatDashboardBinding(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 250),
      );
      return;
    }
    ChatDashboardBinding().dependencies();
    final NavigatorState? shellNav = chatShellNavigatorKey.currentState;
    if (shellNav == null) {
      return;
    }
    isEmbeddedChatDashboardOpen.value = true;
    shellNav
        .push<void>(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const ChatDashboardPageView(),
          ),
        )
        .then((void _) {
          isEmbeddedChatDashboardOpen.value = false;
          if (Get.isRegistered<ChatDashboardController>()) {
            Get.delete<ChatDashboardController>();
          }
        });
  }

  /// When sized/floating, pops the in-shell dashboard route if it is on top.
  /// Returns `true` if a nested route was popped.
  bool tryCloseEmbeddedChatDashboard() {
    final NavigatorState? nav = chatShellNavigatorKey.currentState;
    if (nav == null || !nav.canPop()) {
      return false;
    }
    nav.pop();
    return true;
  }

  // Collapse callback for floating and sized modes
  VoidCallback? _onCollapseCallback;
  void setCollapseCallback(VoidCallback? callback) {
    _onCollapseCallback = callback;
  }

  // Callback for when first initialization completes (for initiallyExpanded mode)
  VoidCallback? _onFirstInitCompleteCallback;
  bool _hasCompletedFirstInit = false;
  void setOnFirstInitCompleteCallback(VoidCallback? callback) {
    _onFirstInitCompleteCallback = callback;
    // If initialization already completed, call callback immediately
    if (_hasCompletedFirstInit && callback != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        callback();
      });
    }
  }

  /// Dismisses [PupauAgentAvatar]'s loading [ChatSkeleton] for sized / initiallyExpanded mode.
  /// Must run for success, API failure, and thrown errors — otherwise the skeleton never clears.
  void _signalFirstInitComplete() {
    _hasCompletedFirstInit = true;
    isChatEntryResolving.value = false;
    _onFirstInitCompleteCallback?.call();
    _onFirstInitCompleteCallback = null;
    update();
  }

  // Guard to prevent concurrent initializations
  bool _isInitializing = false;
  Completer<void>? _initializationCompleter;

  MyMentionTagTextEditingController inputMessageController =
      MyMentionTagTextEditingController();
  RxString inputMessage = "".obs;
  ScrollController chatScrollController = ScrollController();

  /// Scroll slack below the message list so [Scrollable.ensureVisible] can move the
  /// latest user bubble toward the top of the viewport (see [scheduleSentUserBubbleAlign]).
  final GlobalKey scrollAlignSentUserBubbleKey = GlobalKey(
    debugLabel: 'scrollAlignSentUserBubble',
  );

  /// When set, [MessageWithOptionalDateHeader] attaches [scrollAlignSentUserBubbleKey]
  /// to that message for one-shot alignment after send.
  final Rx<String?> pendingScrollAlignUserMessageId = Rx<String?>(null);

  /// Extra scroll slack under the thread ([MessagesList]). Set true only when the user
  /// sends a message in this controller instance; cleared when the chat/conversation resets.
  final RxBool chatExtraBottomPaddingActive = false.obs;

  /// Laid-out height of the latest query's assistant cluster (see [HeightReportingContainer]).
  /// Reduces fixed bottom slack in [MessagesList] while [chatExtraBottomPaddingActive].
  final RxDouble latestQueryAssistantClusterHeight = 0.0.obs;

  Rxn<Assistant> assistant = Rxn<Assistant>();
  RxList<Assistant> taggedAssistants = <Assistant>[].obs;
  Rxn<PupauConversation> conversation = Rxn<PupauConversation>();
  RxList<PupauMessage> messages = <PupauMessage>[].obs;
  RxBool externalSearchVisible = false.obs;
  RxBool hasApiError = false.obs;
  final FocusNode keyboardFocusNode = FocusNode();
  RxBool isLoadingConversation = false.obs;

  /// True until the first [openChatWithConfig] → [initChatController] pass finishes
  /// ([_signalFirstInitComplete]). Also set true at each chat open so the UI never
  /// flashes [EmptyConversationView] before we know real empty vs loading history.
  RxBool isChatEntryResolving = true.obs;
  MessageNotifier messageNotifier = MessageNotifier();
  StreamSubscription? messageSendStream;
  StreamSubscription<SSEModel>? conversationSseSubscription;
  RxBool isStreaming = false.obs;

  /// True while [sendCancel] is awaiting the backend stop acknowledgement.
  /// While true the stop and send buttons are disabled and the stop button
  /// shows a stacked [CircularProgressIndicator] over the stop icon.
  RxBool isStopping = false.obs;
  RxBool isDashboardAvailable = false.obs;
  Worker? _dashboardAvailabilityWorker;
  Worker? _dashboardAttachmentsAvailabilityWorker;

  /// GroupIds (trimmed) whose message group is expanded in the messages list.
  final RxList<String> expandedMessageGroupIds = <String>[].obs;

  /// Bumped on expand/collapse so [Obx] listeners rebuild when set size is unchanged.
  final RxInt messageGroupExpandEpoch = 0.obs;

  bool isMessageGroupExpanded(String groupId) {
    final String trimmedId = groupId.trim();
    if (trimmedId.isEmpty) return false;
    return expandedMessageGroupIds.contains(trimmedId);
  }

  void toggleMessageGroupExpanded(String groupId) {
    final String trimmedId = groupId.trim();
    if (trimmedId.isEmpty) return;

    if (expandedMessageGroupIds.contains(trimmedId)) {
      expandedMessageGroupIds.remove(trimmedId);
    } else {
      expandedMessageGroupIds.add(trimmedId);
    }
    expandedMessageGroupIds.refresh();
    messageGroupExpandEpoch.value++;
    update();
  }

  void _clearExpandedMessageGroups() {
    expandedMessageGroupIds.clear();
    expandedMessageGroupIds.refresh();
    messageGroupExpandEpoch.value++;
    update();
  }

  RxInt assistantsReplying = 0
      .obs; //Set to 1 when sending a message without tags, set to n when sending a message with n tags. Tied to isStreaming logic
  TtsService ttsService = TtsService();
  List<PupauMessage> incomingMessages = [];

  // Streaming backends may not provide groupId; generate one per stream.
  String? _activeStreamingGroupId;

  String _generateStreamingGroupId() =>
      'stream_${DateTime.now().microsecondsSinceEpoch}';

  void _applyActiveStreamingGroupId(PupauMessage message) {
    if (message.groupId.trim().isNotEmpty) return;
    final String? gid = _activeStreamingGroupId;
    if (gid == null || gid.trim().isEmpty) return;
    message.groupId = gid;
  }

  bool _hasRenderableStreamingContent(PupauMessage message) {
    if (message.answer.trim().isNotEmpty) return true;
    if (message.images.isNotEmpty) return true;
    if (message.news.isNotEmpty) return true;
    if (message.organicInfo.isNotEmpty) return true;
    if (message.graphInfo != null) return true;
    if (message.urls.isNotEmpty) return true;
    if (message.relatedSearches.isNotEmpty) return true;
    if (message.toolUseMessage != null) return true;
    if (message.uiToolMessage != null) return true;
    if (message.attachmentTrimming != null) return true;
    if (message.emergencyTrimming != null) return true;
    if (message.transcription != null) return true;
    return false;
  }

  /// Re-syncs every LLM row that may contain `<thinking>` (history load, stream end).
  ///
  /// Ensures sibling tool-use rows exist and share [PupauMessage.groupId] with the
  /// user query + LLM answer after bulk updates.
  void _syncAllInlineThinkingMessages() {
    final Set<String> parentLlmMessageIds = <String>{};
    for (final PupauMessage message in messages) {
      if (message.sourceType == SourceType.llm &&
          !InlineThinkingMessageService.isInlineThinkingMessage(message.id) &&
          TagService.hasThinkingTag(message.answer)) {
        parentLlmMessageIds.add(message.id);
        continue;
      }
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(message.id);
      if (parsed != null) {
        parentLlmMessageIds.add(parsed.parentLlmMessageId);
      }
    }
    for (final String parentId in parentLlmMessageIds) {
      final PupauMessage? llmMessage = messages.firstWhereOrNull(
        (PupauMessage message) =>
            message.id == parentId && message.sourceType == SourceType.llm,
      );
      if (llmMessage == null) {
        continue;
      }
      if (TagService.hasThinkingTag(llmMessage.answer)) {
        _syncInlineThinkingSiblingMessage(llmMessage);
      } else {
        _refreshInlineThinkingSiblingsForParent(llmMessage);
      }
    }
  }

  /// Keeps synthetic thinking siblings aligned after `<thinking>` was stripped from
  /// the parent LLM answer (SSE continues with markdown-only deltas).
  void _refreshInlineThinkingSiblingsForParent(PupauMessage llmMessage) {
    final String parentId = llmMessage.id.trim();
    if (parentId.isEmpty) {
      return;
    }
    for (final PupauMessage thinkingMessage in messages) {
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(
            thinkingMessage.id,
          );
      if (parsed == null || parsed.parentLlmMessageId != parentId) {
        continue;
      }
      final ToolUseThinkingData? thinkingData =
          thinkingMessage.toolUseMessage?.thinkingData;
      thinkingMessage.status =
          InlineThinkingMessageService.normalizeAssistantStatus(
            llmMessage.status,
          );
      final String queryGroupId = InlineThinkingMessageService.queryGroupIdFor(
        llmMessage,
      );
      thinkingMessage.groupId = queryGroupId;
      thinkingMessage.assistantId = llmMessage.assistantId;
      thinkingMessage.assistantType = llmMessage.assistantType;
      thinkingMessage.isCancelled = llmMessage.isCancelled;
      if (thinkingData != null) {
        thinkingMessage.toolUseMessage =
            InlineThinkingMessageService.buildToolUseMessage(
              thinkingMessageId: thinkingMessage.id,
              parentLlmMessageId: parentId,
              queryGroupId: queryGroupId,
              thinkingData: thinkingData,
            );
      }
    }
  }

  /// Removes all synthetic thinking siblings for [parentLlmMessageId].
  void _removeAllInlineThinkingMessagesForParent({
    required String parentLlmMessageId,
  }) {
    messages.removeWhere((PupauMessage message) {
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(message.id);
      if (parsed != null && parsed.parentLlmMessageId == parentLlmMessageId) {
        return true;
      }
      return InlineThinkingMessageService.isInlineThinkingMessage(message.id) &&
          message.toolUseMessage?.messageId == parentLlmMessageId;
    });
    incomingMessages.removeWhere((PupauMessage message) {
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(message.id);
      return parsed != null && parsed.parentLlmMessageId == parentLlmMessageId;
    });
    messages.refresh();
    update();
  }

  /// Drops thinking siblings whose block index is no longer present on the LLM body.
  void _pruneStaleInlineThinkingMessagesForParent({
    required String parentLlmMessageId,
    required Set<int> activeBlockIndices,
  }) {
    messages.removeWhere((PupauMessage message) {
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(message.id);
      if (parsed == null || parsed.parentLlmMessageId != parentLlmMessageId) {
        return false;
      }
      return !activeBlockIndices.contains(parsed.blockIndex);
    });
    incomingMessages.removeWhere((PupauMessage message) {
      final ({String parentLlmMessageId, int blockIndex})? parsed =
          InlineThinkingMessageService.parseInlineThinkingMessageId(message.id);
      if (parsed == null || parsed.parentLlmMessageId != parentLlmMessageId) {
        return false;
      }
      return !activeBlockIndices.contains(parsed.blockIndex);
    });
  }

  /// Extracts inline `<thinking>` into sibling [SourceType.toolUse] rows.
  ///
  /// - Consecutive `<thinking>` blocks → one row (`{llmId}_thinking_1`, …).
  /// - Inserts at `llmIndex + blockIndex` (chrono: user → thinking → … → LLM).
  /// - Strips closed thinking from the LLM [answer] when streaming ends.
  /// - Refreshes each sibling on every SSE chunk.
  void _syncInlineThinkingSiblingMessage(PupauMessage llmMessage) {
    if (llmMessage.sourceType != SourceType.llm ||
        InlineThinkingMessageService.isInlineThinkingMessage(llmMessage.id)) {
      return;
    }

    final String rawAnswer = llmMessage.answer;
    if (!TagService.hasThinkingTag(rawAnswer)) {
      // Thinking was already extracted and stripped; later SSE chunks have no
      // `<thinking>` tag but must not delete the synthetic tool-use siblings.
      _refreshInlineThinkingSiblingsForParent(llmMessage);
      return;
    }

    _applyActiveStreamingGroupId(llmMessage);
    final String queryGroupId = InlineThinkingMessageService.queryGroupIdFor(
      llmMessage,
    );
    if (llmMessage.groupId.trim().isEmpty && queryGroupId.isNotEmpty) {
      llmMessage.groupId = queryGroupId;
    }

    final List<ThinkingTagSegment> segments =
        TagService.groupedConsecutiveThinkingTagSegments(rawAnswer);
    if (segments.isEmpty) {
      _removeAllInlineThinkingMessagesForParent(
        parentLlmMessageId: llmMessage.id,
      );
      return;
    }

    final ToolUseThinkingData fallbackThinkingData = ToolUseThinkingData(
      subject: Strings.thinking.tr,
      thought: '',
    );

    int llmIndex = messages.indexWhere(
      (PupauMessage message) => message.id == llmMessage.id,
    );
    if (llmIndex < 0) {
      addMessage(llmMessage, bypassCheck: true);
      llmIndex = messages.indexWhere(
        (PupauMessage message) => message.id == llmMessage.id,
      );
      if (llmIndex < 0) {
        return;
      }
    }

    final Set<int> activeBlockIndices = <int>{};
    for (final ThinkingTagSegment segment in segments) {
      activeBlockIndices.add(segment.blockIndex);
      final ToolUseThinkingData thinkingData =
          TagService.extractThinkingDataFromMergedThinkingRaw(
            segment.rawSegment,
          ) ??
          fallbackThinkingData;
      final String thinkingId = InlineThinkingMessageService.messageIdFor(
        parentLlmMessageId: llmMessage.id,
        blockIndex: segment.blockIndex,
      );

      PupauMessage? thinkingMessage = messages.firstWhereOrNull(
        (PupauMessage message) => message.id == thinkingId,
      );
      if (thinkingMessage == null) {
        thinkingMessage = InlineThinkingMessageService.buildSiblingMessage(
          parentLlmMessage: llmMessage,
          blockIndex: segment.blockIndex,
          rawThinkingSegment: segment.rawSegment,
          thinkingData: thinkingData,
        );
        messages.insert(llmIndex + segment.blockIndex, thinkingMessage);
      } else {
        thinkingMessage.answer = segment.rawSegment;
        thinkingMessage.status =
            InlineThinkingMessageService.normalizeAssistantStatus(
              llmMessage.status,
            );
        thinkingMessage.groupId = queryGroupId;
        thinkingMessage.assistantId = llmMessage.assistantId;
        thinkingMessage.assistantType = llmMessage.assistantType;
        thinkingMessage.isCancelled = llmMessage.isCancelled;
        thinkingMessage.sourceType = SourceType.toolUse;
        thinkingMessage.toolUseType = ToolUseType.nativeToolsThinking;
        thinkingMessage.type = MessageType.nativeTools;
        thinkingMessage.toolUseMessage =
            InlineThinkingMessageService.buildToolUseMessage(
              thinkingMessageId: thinkingId,
              parentLlmMessageId: llmMessage.id,
              queryGroupId: queryGroupId,
              thinkingData: thinkingData,
            );
      }
    }

    _pruneStaleInlineThinkingMessagesForParent(
      parentLlmMessageId: llmMessage.id,
      activeBlockIndices: activeBlockIndices,
    );

    final bool hasOpenThinkingBlock = segments.any(
      (ThinkingTagSegment segment) => segment.isOpen,
    );
    // Keep `<thinking>` in [answer] while SSE is active; strip only when the
    // stream ends. UI already strips for markdown display.
    if (!hasOpenThinkingBlock && !isStreaming.value) {
      llmMessage.answer = TagService.stripThinkingForMarkdown(rawAnswer);
    }

    messages.refresh();
    update();
  }

  RxBool isLoadingTitle = false.obs;
  RxDouble messageInputFieldHeight = (DeviceService.isTablet ? 74.0 : 58.0).obs;
  RxBool isMessageInputFieldFocused = false.obs;
  double listHeight = 0.0;

  /// Global loading state (dots, text, web search, or tool-use).
  /// For tools, this can represent multiple concurrent tool loadings.
  Rx<LoadingMessage> loadingMessage = LoadingMessage(
    message: "",
    loadingType: LoadingType.dots,
  ).obs; //Used as simple loading message, Layer message for pipeline, query message for websearch
  bool isConversationHistoryLoaded = false;

  /// Active tool loadings keyed by tool name. This allows multiple tools
  /// (pending or running) to be shown simultaneously.
  /// Reactive so that [isLoadingMessageActive] and any [Obx] that reads it
  /// rebuilds automatically whenever a tool is added or removed.
  final RxMap<String, ToolUseType> activeToolLoadings =
      <String, ToolUseType>{}.obs;

  /// Skills currently active in this conversation (SSE + latest history snapshot).
  final RxMap<String, SkillLoadedInfo> conversationActiveSkills =
      <String, SkillLoadedInfo>{}.obs;

  // Loading tool bubble UX: expand/collapse + elapsed timer.
  final RxSet<String> expandedLoadingTools = <String>{}.obs;
  final RxSet<String> userToggledLoadingTools = <String>{}.obs;
  final Map<String, DateTime> _loadingToolStartedAt = <String, DateTime>{};
  final RxInt loadingToolsTick = 0.obs;
  Timer? _loadingToolsTimer;

  void _ensureLoadingToolsTimer() {
    if (_loadingToolsTimer != null) return;
    _loadingToolsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      loadingToolsTick.value++;
    });
  }

  void _stopLoadingToolsTimerIfIdle() {
    if (_loadingToolStartedAt.isNotEmpty) return;
    _loadingToolsTimer?.cancel();
    _loadingToolsTimer = null;
  }

  void markToolLoadingStarted(String toolName) {
    final String key = toolName.trim();
    if (key.isEmpty) return;
    _loadingToolStartedAt.putIfAbsent(key, () => DateTime.now());
    _ensureLoadingToolsTimer();
  }

  void markToolLoadingEnded(String toolName) {
    final String key = toolName.trim();
    if (key.isEmpty) return;
    _loadingToolStartedAt.remove(key);
    expandedLoadingTools.remove(key);
    expandedLoadingTools.refresh();
    userToggledLoadingTools.remove(key);
    userToggledLoadingTools.refresh();
    _stopLoadingToolsTimerIfIdle();
  }

  int getToolLoadingSeconds(String toolName) {
    final String key = toolName.trim();
    final DateTime? started = _loadingToolStartedAt[key];
    if (started == null) return 0;
    // Depend on tick so UI updates once per second.
    loadingToolsTick.value;
    final int seconds = DateTime.now().difference(started).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  bool isLoadingToolExpanded(String toolName, {ToolUseType? toolUseType}) {
    final String key = toolName.trim();
    final bool toggled = expandedLoadingTools.contains(key);
    final bool initiallyExpanded = ToolUseService.isInitiallyExpandedTool(
      toolUseType,
    );
    return initiallyExpanded ? !toggled : toggled;
  }

  void toggleLoadingToolExpanded(String toolName) {
    final String key = toolName.trim();
    if (key.isEmpty) return;
    if (expandedLoadingTools.contains(key)) {
      expandedLoadingTools.remove(key);
    } else {
      expandedLoadingTools.add(key);
    }
    expandedLoadingTools.refresh();
    userToggledLoadingTools.add(key);
    userToggledLoadingTools.refresh();
  }

  /// Optional per-tool status label for tools that emit TOOL_PARTIAL_RESULT,
  /// e.g. document_create/document_update phases.
  /// Reactive so that the loading animation label updates live.
  final RxMap<String, String> toolPartialStatuses = <String, String>{}.obs;

  /// Rich loading label for the JIT attachment tools (list_attachments,
  /// attachment_outline, attachment_read, attachment_grep, attachment_search),
  /// derived from TOOL_USE_START's `typeDetails.toolArgs` (e.g. "Reading
  /// report.pdf (lines 1-200)"). Keyed by tool name, same as
  /// [activeToolLoadings]. Falls back to a generic per-tool label when args
  /// aren't known yet (TOOL_PENDING).
  final RxMap<String, String> attachmentToolLoadingLabels =
      <String, String>{}.obs;

  // Tool args streaming buffers (TOOL_ARGS_DELTA). Keyed by toolId.
  final Map<String, String> _toolArgsDeltaBuffers = <String, String>{};
  final RxMap<String, String> toolArgsPreviewToolIdByName =
      <String, String>{}.obs;
  final RxMap<String, String> toolArgsPreviewContentsById =
      <String, String>{}.obs;
  final RxMap<String, String> toolArgsPreviewTitlesById =
      <String, String>{}.obs;

  RxBool toolsFabExpanded = false.obs;

  //Conversation pagination variables
  bool isConversationLastPage = false;
  bool isLoadingConversationPage = false;
  int conversationPage = 0;
  int conversationItemsLoaded = 0;

  //Conversation scroll variables
  /// User preference for "magnetic" auto-scroll to bottom.
  /// Default is disabled (open lock) and only changes on explicit user tap.
  final RxBool autoScrollMagnetEnabled = false.obs;

  /// Transient runtime state: whether auto-scroll is currently allowed.
  /// This is NOT a preference. It's suspended by any user manual scroll,
  /// and re-enabled automatically when the user returns to bottom AND
  /// the magnet preference is enabled.
  bool autoScrollEnabled = false;

  /// Sticky runtime state: once the user manually scrolls, keep auto-scroll
  /// suspended until the user explicitly returns to bottom (or taps the arrow).
  /// Programmatic scrolls to bottom must NOT clear this.
  bool autoScrollSuspendedByUser = false;
  RxBool isAtTop = true.obs;
  RxBool isAtBottom = true.obs;

  //Mention variables
  RxBool isMentionAvailable = false.obs;
  List<Assistant> assistants = [];
  RxList<Assistant> filteredAssistants = <Assistant>[].obs;
  RxString mentionValue = "".obs;

  //Web Search
  RxBool isWebSearchAvailable = false
      .obs; //If the assistant has web search enabled from the assistant settings
  RxBool isWebSearchActive = false
      .obs; //If the web search is active in the current conversation (in chat toggle)

  //Pipeline & Websearch
  Rxn<WebSearchType> currentWebSearchType = Rxn<WebSearchType>();

  // Settings
  RxBool showNerdStats = false.obs;
  RxBool isAttachmentAvailable = false.obs;
  RxBool isActionBarAlwaysVisible = true.obs;
  RxBool hideInputBox = false.obs;

  // Fork
  RxBool isForking = false.obs;
  RxString forkMessageId = "".obs;
  RxString forkConversationTitle = "".obs;
  TextEditingController forkConversationTitleController =
      TextEditingController();

  /// Shared with [showEditMessageModal]; disposed in [onClose] only.
  TextEditingController editMessageTextController = TextEditingController();

  // Tool Use Management
  RxSet<String> expandedToolUseMessages = <String>{}.obs;
  RxList<String> userToggledToolUseMessages = <String>[].obs;

  // UI Tool Bubble Visibility Management
  RxSet<String> hiddenUiToolMessages = <String>{}.obs;

  /// Message IDs for which the attachment trimming modal was opened at least once (persisted in prefs).
  RxSet<String> attachmentTrimmingOpenedMessageIds = <String>{}.obs;

  // Image Full Screen
  Rxn<ChatImage> selectedImage = Rxn<ChatImage>();
  Map<String, Uint8List> cachedToolUseImages = {};

  // Audio recording
  RxBool isRecording = false.obs;
  String? _lastFailedAudioFilePath;
  Rx<Duration> recordingDuration = Duration.zero.obs;
  Timer? _recordingTimer;

  // Voice mode
  RxBool isVoiceMode = false.obs;
  RxDouble voiceAmplitude = 0.0.obs;
  RxBool isVoiceDetected = false.obs;
  RxBool isVoicePlaying = false.obs;
  RxDouble voiceSilenceProgress = 0.0.obs;
  final VoicePlaybackService _voicePlaybackService = VoicePlaybackService();
  Timer? _voiceAmplitudeTimer;
  Timer? _voiceSilenceTimer;
  DateTime? _voiceSilenceStart;
  bool _voiceSessionHadSpeech = false;
  static const double _voiceAmplitudeThreshold = 0.2;
  static const Duration _voiceSilenceDelay = Duration(milliseconds: 2500);

  // SSE idle watchdog: if no SSE events arrive for too long, stop streaming.
  static const Duration _sseIdleTimeout = Duration(seconds: 30);
  Timer? _sseIdleTimer;

  void _cancelSseIdleTimer() {
    _sseIdleTimer?.cancel();
    _sseIdleTimer = null;
  }

  void _bumpSseIdleTimer() {
    if (!isStreaming.value) return;
    _sseIdleTimer?.cancel();
    _sseIdleTimer = Timer(_sseIdleTimeout, () {
      if (!isStreaming.value) return;
      stopActiveStreams();
    });
  }

  // KB References
  List<KbReference> kbReferencesBackup =
      []; //Used in case first message is MessageType.kb and following messages are not SourceType.llm
  List<MemoryReference> memoryReferencesBackup = <MemoryReference>[];
  List<MemoryAlways> alwaysMemoriesBackup = <MemoryAlways>[];

  // RAG grounding citations (§1.2/§1.4 of the citations spec) — same
  // forward-fill idea as [kbReferencesBackup]: the `kb` frame's live
  // IMPLICIT `groundingSources` arrives before the LLM row exists yet.
  List<GroundingSource> groundingSourcesBackup = <GroundingSource>[];
  Timer? _groundingRefetchTimer;

  // Translations
  static bool _translationsInitialized = false;

  // Assistant loading state (for welcome message / initial info)
  RxBool isLoadingAssistant = false.obs;

  // THINKING (extended reasoning)
  RxBool thinkingEnabled = false.obs;
  RxString thinkingEffort = "".obs; // raw provider value; empty means unset

  // Event tracking variables
  DateTime? _currentMessageStartTime;
  bool _hasReceivedFirstToken = false;
  bool _isFirstMessage = true;

  @override
  onInit() {
    setDefaultMessageInputFieldHeight();
    _syncDashboardAvailability();
    _dashboardAvailabilityWorker = ever<List<PupauMessage>>(
      messages,
      (_) => _syncDashboardAvailability(),
    );
    if (Get.isRegistered<PupauAttachmentsController>()) {
      _dashboardAttachmentsAvailabilityWorker = ever<List<Attachment>>(
        Get.find<PupauAttachmentsController>().attachments,
        (_) => _syncDashboardAvailability(),
      );
    }
    ever(isStreaming, _onVoiceModeStreamingChanged);
    openChatWithConfig(pupauConfig);
    ttsService.initTextToSpeach(config: pupauConfig);
    PupauSharedPreferences.init();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _loadAttachmentTrimmingOpenedIds();
  }

  Future<void> _loadAttachmentTrimmingOpenedIds() async {
    await PupauSharedPreferences.init();
    final Set<String> ids =
        PupauSharedPreferences.getAttachmentTrimmingOpenedMessageIds();
    attachmentTrimmingOpenedMessageIds.clear();
    attachmentTrimmingOpenedMessageIds.addAll(ids);
    attachmentTrimmingOpenedMessageIds.refresh();
  }

  void _updateBootStatus(BootState status) {
    PupauEventService.instance.emitPupauEvent(
      PupauEvent(
        type: UpdateConversationType.componentBootStatus,
        payload: {
          "bootState": status.value,
          "assistantId": assistantId,
          "assistantType": assistant.value?.type ?? AssistantType.assistant,
        },
      ),
    );
  }

  @override
  onClose() {
    final NavigatorState? shellNav = chatShellNavigatorKey.currentState;
    if (shellNav != null && shellNav.mounted) {
      while (shellNav.canPop()) {
        shellNav.pop();
      }
    }
    isEmbeddedChatDashboardOpen.value = false;
    if (Get.isRegistered<ChatDashboardController>()) {
      Get.delete<ChatDashboardController>();
    }
    _dashboardAvailabilityWorker?.dispose();
    _dashboardAvailabilityWorker = null;
    _dashboardAttachmentsAvailabilityWorker?.dispose();
    _dashboardAttachmentsAvailabilityWorker = null;
    _voiceAmplitudeTimer?.cancel();
    _voiceSilenceTimer?.cancel();
    _groundingRefetchTimer?.cancel();
    if (isRecording.value) {
      isRecording.value = false;
      AudioRecordingService.cancelRecording();
    }
    isVoiceMode.value = false;
    _voicePlaybackService.dispose();
    _cancelSseIdleTimer();
    messageSendStream?.cancel();
    conversationSseSubscription?.cancel();
    chatScrollController.dispose();
    editMessageTextController.dispose();
    // Set boot status to OFF when component is closed
    _updateBootStatus(BootState.off);
    super.onClose();
  }

  void _syncDashboardAvailability() {
    final bool hasToolMessages = messages.any((PupauMessage message) {
      if (message.sourceType != SourceType.toolUse) {
        return false;
      }
      final ToolUseMessage? toolUseMessage = message.toolUseMessage;
      if (toolUseMessage == null) {
        return false;
      }
      if (toolUseMessage.type == ToolUseType.nativeToolsToDoList &&
          toolUseMessage.toDoListData != null) {
        return true;
      }
      if (pupauMessageQualifiesForDashboardDocumentTool(message)) {
        return true;
      }
      if (pupauMessageQualifiesForDashboardWebSection(message)) {
        return true;
      }
      if (pupauMessageQualifiesForDashboardNativeDatabase(message)) {
        return true;
      }
      if (pupauMessageQualifiesForDashboardMailTool(message)) {
        return true;
      }
      if (pupauMessageQualifiesForDashboardSmtpTool(message)) {
        return true;
      }
      return false;
    });
    final bool hasAttachments =
        Get.isRegistered<PupauAttachmentsController>() &&
        Get.find<PupauAttachmentsController>().attachments.isNotEmpty;
    isDashboardAvailable.value = hasToolMessages || hasAttachments;
  }

  /// Stops any active SSE streams so the UI no longer receives updates.
  ///
  /// This is important for "exit" flows that collapse/hide the widget
  /// without destroying the controller (GetX controllers can outlive the view).
  void stopActiveStreams() {
    _cancelSseIdleTimer();
    _groundingRefetchTimer?.cancel();
    _loadingToolsTimer?.cancel();
    _loadingToolsTimer = null;
    _loadingToolStartedAt.clear();
    expandedLoadingTools.clear();
    expandedLoadingTools.refresh();
    userToggledLoadingTools.clear();
    userToggledLoadingTools.refresh();
    messageSendStream?.cancel();
    messageSendStream = null;

    conversationSseSubscription?.cancel();
    conversationSseSubscription = null;

    // Stop any local "streaming" UI state immediately.
    isStreaming.value = false;
    assistantsReplying.value = 0;
    resetLoadingMessage();
    _currentMessageStartTime = null;
    _hasReceivedFirstToken = false;
    autoScrollEnabled = false;
    update();
  }

  void clearToolArgsPreviewCache() {
    ToolArgsDeltaService.clearPreviewCache(
      toolIdByName: toolArgsPreviewToolIdByName,
      previewsById: toolArgsPreviewContentsById,
      titlesById: toolArgsPreviewTitlesById,
      rawBuffersById: _toolArgsDeltaBuffers,
    );
    toolArgsPreviewToolIdByName.refresh();
    toolArgsPreviewContentsById.refresh();
    toolArgsPreviewTitlesById.refresh();
  }

  //CONTROLLER - CONVERSATIONS INIT

  /// Resets all chat state when the chat is opened
  /// This ensures a fresh state each time the chat is opened
  void resetChatState({required bool clearConversationStarters}) {
    exitVoiceModeIfActive();
    if (isRecording.value) cancelRecording();
    _hasCompletedFirstInit = false;
    PupauEventService.instance.emitPupauEvent(
      PupauEvent(
        type: UpdateConversationType.resetConversation,
        payload: {
          "assistantId": assistantId,
          "assistantType": assistant.value?.type ?? AssistantType.assistant,
        },
      ),
    );
    // Reset conversation and messages
    conversation.value = null;
    messages.clear();
    resetExtraBottomScrollPadding();
    _clearExpandedMessageGroups();
    incomingMessages.clear();
    conversationActiveSkills.clear();
    conversationActiveSkills.refresh();
    isConversationHistoryLoaded = false;

    // Reset streaming and loading states
    isStreaming.value = false;
    assistantsReplying.value = 0;
    isLoadingConversation.value = false;
    isLoadingTitle.value = false;
    hasApiError.value = false;

    // Reset input
    inputMessageController.clear();
    inputMessage.value = "";
    setDefaultMessageInputFieldHeight();

    // Reset tagged assistants and mentions
    clearTaggedAssistants();
    mentionValue.value = "";
    filteredAssistants.clear();

    // Reset conversation starters only when switching assistants
    if (clearConversationStarters) {
      conversationStarters.clear();
      conversationStarters.refresh();
    }

    // Reset loading message
    resetLoadingMessage();

    // Reset tool use states
    expandedToolUseMessages.clear();
    userToggledToolUseMessages.clear();
    hiddenUiToolMessages.clear();

    // Reset web search
    isWebSearchActive.value = false;
    currentWebSearchType.value = null;
    externalSearchVisible.value = false;

    // Reset conversation pagination
    resetConversationPagination();

    // Reset scroll
    isAtTop.value = true;
    isAtBottom.value = true;
    // Default (per conversation): magnet disabled.
    autoScrollMagnetEnabled.value = false;
    autoScrollEnabled = false;
    listHeight = 0.0;

    // Reset event tracking variables
    _currentMessageStartTime = null;
    _hasReceivedFirstToken = false;
    _isFirstMessage = true;

    // Reset other states
    selectedImage.value = null;
    cachedToolUseImages.clear();
    kbReferencesBackup.clear();
    toolsFabExpanded.value = false;
    forkMessageId.value = "";
    forkConversationTitle.value = "";
    forkConversationTitleController.clear();

    // Reset message notifier
    messageNotifier = MessageNotifier();

    clearToolArgsPreviewCache();

    // Ensure SSE subscriptions are stopped (otherwise the controller can
    // keep updating messages even after the UI changes).
    stopActiveStreams();

    // Clear attachments (conversation-scoped)
    if (Get.isRegistered<PupauAttachmentsController>()) {
      Get.find<PupauAttachmentsController>().clearAttachments();
    }

    // Stop TTS if running
    ttsService.stopReading();

    // Refresh observables
    messages.refresh();
    update();
  }

  /// Called when chat is opened (via PupauChatUtils or tapping avatar)
  /// Resets conversation state and updates config if assistant changed
  /// Re-initializes the chat every time it's called (even with same config)
  Future<void> openChatWithConfig(PupauConfig? newConfig) async {
    isChatEntryResolving.value = true;
    update();
    PupauConfig? resolvedConfig = newConfig;
    if (resolvedConfig != null &&
        resolvedConfig.assistantId.trim().isEmpty &&
        _cachedAssistantId != null &&
        _cachedAssistantId!.trim().isNotEmpty) {
      // If the host rebuilt config from bearer token only and assistantId
      // is temporarily empty, keep the last known assistantId.
      if (resolvedConfig.bearerToken != null &&
          resolvedConfig.bearerToken!.trim().isNotEmpty) {
        resolvedConfig = PupauConfig.createWithToken(
          bearerToken: resolvedConfig.bearerToken!,
          assistantId: _cachedAssistantId!,
          apiUrl: resolvedConfig.apiUrl,
          isMarketplace: resolvedConfig.isMarketplace,
          conversationId: resolvedConfig.conversationId,
          isAnonymous: resolvedConfig.isAnonymous,
          language: resolvedConfig.language,
          googleMapsApiKey: resolvedConfig.googleMapsApiKey,
          hideInputBox: resolvedConfig.hideInputBox,
          widgetMode: resolvedConfig.widgetMode,
          sizedConfig: resolvedConfig.sizedConfig,
          floatingConfig: resolvedConfig.floatingConfig,
          showNerdStats: resolvedConfig.showNerdStats,
          hideAudioRecordingButton: resolvedConfig.hideAudioRecordingButton,
          customProperties: resolvedConfig.customProperties,
          conversationStarters: resolvedConfig.conversationStarters,
          appBarConfig: resolvedConfig.appBarConfig,
          drawerConfig: resolvedConfig.drawerConfig,
          resetChatOnOpen: resolvedConfig.resetChatOnOpen,
          initialWelcomeMessage: resolvedConfig.initialWelcomeMessage,
        );
      }
    }

    // Wait for any ongoing initialization to complete before starting a new one
    // This ensures proper config updates when switching agents
    if (_isInitializing && _initializationCompleter != null) {
      await _initializationCompleter!.future;
    }

    final bool assistantChanged =
        pupauConfig?.assistantId != resolvedConfig?.assistantId ||
        pupauConfig?.isMarketplace != resolvedConfig?.isMarketplace;
    final bool anonymousChanged =
        pupauConfig?.isAnonymous != resolvedConfig?.isAnonymous;
    final bool resetChatOnOpen = resolvedConfig?.resetChatOnOpen ?? true;

    if (resolvedConfig != null) {
      pupauConfig = resolvedConfig;
      ApiUrls.setApiUrlOverride(resolvedConfig.apiUrl);
      hideInputBox.value = resolvedConfig.hideInputBox;
      final String bearerForProfile = resolvedConfig.bearerToken?.trim() ?? "";
      if (bearerForProfile.isNotEmpty) {
        UserService.syncUserProfileIfBearerChanged(bearerForProfile);
      }
    }
    // Show new agent in UI immediately from cache if available (no network delay)
    applyCachedAssistantIfAvailable();
    if (resetChatOnOpen) {
      resetChatState(clearConversationStarters: assistantChanged);
    } else if (assistantChanged || anonymousChanged) {
      resetChatState(clearConversationStarters: assistantChanged);
    }
    _updateBootStatus(BootState.pending);

    // Initialize chat with current config (always re-initialize when chat is opened)
    _isInitializing = true;
    final completer = Completer<void>();
    _initializationCompleter = completer;
    try {
      await initChatController();
      if (!completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
      rethrow;
    } finally {
      _isInitializing = false;
      // Only clear if this is still the current completer (in case a new init started)
      if (_initializationCompleter == completer) {
        _initializationCompleter = null;
      }
    }
    update();
  }

  Future<void> initChatController() async {
    try {
      isChatEntryResolving.value = true;
      update();
      // Show cached assistant immediately so app bar updates before any network call
      applyCachedAssistantIfAvailable();
      if (assistant.value?.id.trim().isNotEmpty == true) {
        _cachedAssistantId = assistant.value!.id;
      }
      initScrollControllers();
      initLanguage();
      hasApiError.value = false;

      // Always call single-assistant API when chat is opened (no dependency on AssistantsController).
      // This guarantees the assistant is loaded every time, including welcome for marketplace.
      if (assistantId.isNotEmpty) {
        isLoadingAssistant.value = true;
        try {
          final Assistant? a = await AssistantService.getAssistant(
            assistantId,
            isMarketplace,
          );
          if (a != null) {
            assistant.value = a;
            if (a.id.trim().isNotEmpty) {
              _cachedAssistantId = a.id;
            }
            _preserveInitialWelcomeIfAssistantEmpty();
            assistant.refresh();
            update();
            if (Get.isRegistered<PupauAssistantsController>()) {
              final assistantsController =
                  Get.find<PupauAssistantsController>();
              assistants = assistantsController.assistants;
              final int idx = assistantsController.assistants.indexWhere(
                (x) => x.id == a.id && x.type == a.type,
              );
              if (idx >= 0) {
                assistantsController.assistants[idx] = a;
              } else {
                assistantsController.assistants.add(a);
              }
              assistantsController.assistants.refresh();
              assistantsController.update();
            }
          }
        } finally {
          isLoadingAssistant.value = false;
        }
      }

      // Only fetch again if we don't have the assistant yet (e.g. first fetch failed or was skipped)
      if (assistant.value == null) {
        await getAssistant();
      } else {
        await setAssistantSettings();
      }
      messageNotifier.setAssistantId(assistant.value?.id ?? "");
      if (assistant.value != null) {
        // Component successfully booted - config received and first remote call succeeded
        _updateBootStatus(BootState.ok);
        if (DeviceService.isTablet) setDefaultMessageInputFieldHeight();
        if (hasApiError.value) {
          _updateBootStatus(BootState.error);
          _signalFirstInitComplete();
          return;
        }
        if (!isAnonymous &&
            pupauConfig?.conversationId != null &&
            pupauConfig?.conversationId?.trim() != "") {
          await loadConversation(pupauConfig?.conversationId ?? "");
        }

        _signalFirstInitComplete();
      } else {
        _updateBootStatus(BootState.error);
        _signalFirstInitComplete();
      }
    } catch (e, stackTrace) {
      _updateBootStatus(BootState.error);
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error initializing chat controller: ${e.toString()}",
            "errorType": e.runtimeType.toString(),
            "stackTrace": stackTrace.toString(),
            "assistantId": assistantId,
            "isMarketplace": isMarketplace,
            "isAnonymous": isAnonymous,
            "conversationId": pupauConfig?.conversationId,
            "configExists": pupauConfig != null,
            "assistantExists": assistant.value != null,
          },
        ),
      );
      _signalFirstInitComplete();
    }
  }

  void resetConversation() {
    conversation.value = null;
    stopActiveStreams();
    clearToolArgsPreviewCache();
    messages.clear();
    resetExtraBottomScrollPadding();
    _clearExpandedMessageGroups();
    conversationActiveSkills.clear();
    conversationActiveSkills.refresh();
    clearTaggedAssistants();
    resetLoadingMessage();
    ttsService.stopReading();
    hasApiError.value = false;
    messages.refresh();
    setExternalSearchButton(false);
    expandedToolUseMessages.clear();
    userToggledToolUseMessages.clear();
    hiddenUiToolMessages.clear();
    resetConversationPagination();
    Get.find<PupauAttachmentsController>().clearAttachments();
    update();
    messages.refresh();
    update();
  }

  Future<void> createNewConversation() async {
    try {
      resetLoadingMessage();
      update();
      if (assistant.value != null) {
        conversation.value = await ConversationService.createConversation(
          assistantId,
          isMarketplace,
          isAnonymous: pupauConfig?.isAnonymous ?? false,
        );
        if (conversation.value == null) resetConversation();
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.newConversation,
            payload: {
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversation": conversation.value!,
            },
          ),
        );
        isConversationHistoryLoaded = false;
        return;
      }
    } catch (e, stackTrace) {
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error creating new conversation: ${e.toString()}",
            "errorType": e.runtimeType.toString(),
            "stackTrace": stackTrace.toString(),
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "assistantExists": assistant.value != null,
          },
        ),
      );
    }
  }

  void setMessageInputFieldFocused(bool isFocused) {
    isMessageInputFieldFocused.value = isFocused;
    PupauEventService.instance.emitPupauEvent(
      PupauEvent(
        type: UpdateConversationType.inputFieldFocusChanged,
        payload: {"isFocused": isFocused},
      ),
    );
    update();
  }

  /// Welcome message to show: from assistant once loaded, otherwise from
  /// [pupauConfig.initialWelcomeMessage] if provided (e.g. by host from list).
  String get effectiveWelcomeMessage {
    final Assistant? currentAssistant = assistant.value;
    if (currentAssistant != null &&
        currentAssistant.welcomeMessage.trim() != "") {
      return currentAssistant.welcomeMessage;
    }
    return pupauConfig?.initialWelcomeMessage ?? "";
  }

  /// When the assistant's welcome message is empty, backfill from config's
  /// [initialWelcomeMessage] so we don't override the host-provided message.
  void _preserveInitialWelcomeIfAssistantEmpty() {
    final Assistant? a = assistant.value;
    final String? initial = pupauConfig?.initialWelcomeMessage;
    if (a == null) return;
    if (a.welcomeMessage.trim().isNotEmpty) return;
    if (initial == null || initial.trim().isEmpty) return;
    a.welcomeMessage = initial.trim();
    assistant.refresh();
    update();
  }

  /// Applies the assistant from [PupauAssistantsController] cache if present for the current
  /// [pupauConfig] assistantId. Synchronous, no network. Use so the UI shows the correct agent
  /// immediately when opening or switching chat, before [getAssistant] returns.
  void applyCachedAssistantIfAvailable() {
    final String? id = pupauConfig?.assistantId;
    if (id == null || id.isEmpty) return;
    if (!Get.isRegistered<PupauAssistantsController>()) return;
    final AssistantType type = pupauConfig?.isMarketplace == true
        ? AssistantType.marketplace
        : AssistantType.assistant;
    final Assistant? cached = Get.find<PupauAssistantsController>()
        .getAssistantById(id, type);
    if (cached != null) {
      assistant.value = cached;
      _preserveInitialWelcomeIfAssistantEmpty();
      assistant.refresh();
      update();
    }
  }

  Future<void> getAssistant() async {
    try {
      isLoadingAssistant.value = true;
      final String id = pupauConfig?.assistantId ?? "";
      if (id.isEmpty) return;
      assistant.value = await AssistantService.getAssistant(id, isMarketplace);
      _preserveInitialWelcomeIfAssistantEmpty();
      assistant.refresh();
      if (assistant.value == null) {
        hasApiError.value = true;
        _updateBootStatus(BootState.error);
        update();
        return;
      }
      // Keep PupauAssistantsController cache in sync so future openings (and
      // applyCachedAssistantIfAvailable) have the latest welcomeMessage and
      // other fields without waiting on the network again.
      if (Get.isRegistered<PupauAssistantsController>()) {
        final PupauAssistantsController assistantsController =
            Get.find<PupauAssistantsController>();
        final Assistant? current = assistant.value;
        if (current == null) return;
        final int existingIndex = assistantsController.assistants.indexWhere(
          (a) => a.id == current.id && a.type == current.type,
        );
        if (existingIndex >= 0) {
          assistantsController.assistants[existingIndex] = current;
          assistantsController.assistants.refresh();
          assistantsController.update();
        } else {
          assistantsController.assistants.add(current);
          assistantsController.assistants.refresh();
          assistantsController.update();
        }
      }
      setAssistantSettings();
      // Boot status will be set to OK in initChatController after successful initialization
    } catch (e, stackTrace) {
      _updateBootStatus(BootState.error);
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error getting assistant: ${e.toString()}",
            "errorType": e.runtimeType.toString(),
            "stackTrace": stackTrace.toString(),
            "assistantId": assistantId,
            "isMarketplace": isMarketplace,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "configExists": pupauConfig != null,
            "configAssistantId": pupauConfig?.assistantId,
          },
        ),
      );
    } finally {
      isLoadingAssistant.value = false;
    }
  }

  /// Reloads the current assistant from the API using [pupauConfig].
  /// Use this when config (e.g. assistantId or API settings) has changed and the UI
  /// should reflect the latest assistant data without reopening the chat.
  Future<void> reloadCurrentAssistant() async {
    await getAssistant();
    update();
  }

  // MESSAGES

  Future<void> sendMessage(String query, bool isExternalSearch) async {
    keyboardFocusNode.unfocus();
    resetLoadingMessage();
    currentWebSearchType.value = null;
    setExternalSearchButton(false);
    messageNotifier = MessageNotifier();
    messageNotifier.setAssistantId(assistant.value?.id ?? "");
    incomingMessages = [];
    inputMessageController.clear();
    inputMessage.value = "";
    kbReferencesBackup = [];
    isStreaming.value = true;
    chatExtraBottomPaddingActive.value = true;
    // Each new query: full bottom slack until this turn's assistant cluster is measured.
    latestQueryAssistantClusterHeight.value = 0.0;
    update();
    setDefaultMessageInputFieldHeight();

    // Track message start time for metrics
    _currentMessageStartTime = DateTime.now();
    _hasReceivedFirstToken = false;
    List<Attachment> attachments =
        Get.find<PupauAttachmentsController>().getAttachments;
    final PupauMessage senderMessage = PupauMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      attachments: attachments
          .where((Attachment attachment) => !attachment.isShown)
          .toList(),
      query: query,
      answer: "",
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      assistantId: assistantId,
      assistantType: assistant.value?.type ?? AssistantType.assistant,
    );
    _activeStreamingGroupId = _generateStreamingGroupId();
    senderMessage.groupId = _activeStreamingGroupId ?? "";
    for (Attachment attachment in attachments) {
      attachment.isShown = true;
    }
    addMessage(senderMessage, bypassCheck: true);
    scrollToUserMessage(senderMessage.id);
    addTaggedAssistants();
    query = MessageService.generateMultiAgentMessage(query, taggedAssistants);
    if (conversation.value == null) await createNewConversation();
    if (conversation.value == null) return;
    bool isFirstSSEData = true;
    listHeight =
        chatScrollController.positions.lastOrNull?.maxScrollExtent ??
        0; //Height of the scrollview, used to animate bottom scroll only if the scrollable height changes
    messageNotifier.setConversationId(conversation.value?.id ?? "");
    PupauEventService.instance.emitPupauEvent(
      PupauEvent(
        type: UpdateConversationType.messageSent,
        payload: {
          "assistantId": assistantId,
          "assistantType": assistant.value?.type ?? AssistantType.assistant,
          "conversationId": conversation.value?.id ?? "",
          "query": query,
        },
      ),
    );
    Stream<SSEModel>? sseStream = await SSEService.createSSEStream(
      assistantId,
      conversation.value?.id ?? "",
      conversation.value?.token ?? "",
      query,
      isExternalSearch: isExternalSearch,
      isWebSearch: isWebSearchActive.value,
      chatController: this,
    );
    if (sseStream != null) {
      _bumpSseIdleTimer();
    }
    messageSendStream = sseStream?.listen(
      (event) {
        _bumpSseIdleTimer();
        setLastEventId(event);
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, isExternalSearch);
          if (isFirstSSEData) {
            isFirstSSEData = false;
          }
        }
      },
      onError: (e) {
        _cancelSseIdleTimer();
        showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.apiErrorSendMessage.tr}",
        );
        manageCancelAndErrorMessage();
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.error,
            payload: {
              "error": "Erorr sending message: ${e.toString()}",
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversationId": conversation.value?.id ?? "",
            },
          ),
        );
      },
      onDone: () {
        _cancelSseIdleTimer();
      },
    );
  }

  void manageSSEData(Map<String, dynamic> data, bool isExternalSearch) {
    // Audio events from voice-mode responses must be routed before message parsing.
    final VoiceSseEventType sseType =
        voiceSseEventTypeFromString(getString(data['type']));
    if (MessageService.isVoiceAudioEvent(sseType)) {
      _handleVoiceAudioEvent(sseType, data);
      return;
    }
    PupauMessage newMessage = PupauMessage.fromSseStream(data);
    manageChatAutoScroll();
    Future.delayed(Duration(milliseconds: 250), () {
      manageChatAutoScroll();
    });
    if (newMessage.type == MessageType.skillLoaded ||
        newMessage.type == MessageType.skillUnloaded) {
      handleSkillSseEvent(newMessage);
      return;
    }
    // TOOL_USE_START with typeDetails.toolName "skill_load"/"skill_unload" and
    // typeDetails.nativeTool.id "SKILL" is an alternative skill event format.
    if (newMessage.type == MessageType.toolUseStart) {
      final dynamic td = data['typeDetails'];
      if (td is Map) {
        final String tdToolName = (td['toolName']?.toString() ?? '')
            .toLowerCase()
            .trim();
        final String nativeId = (td['nativeTool']?['id']?.toString() ?? '')
            .toUpperCase();
        if ((tdToolName == 'skill_load' || tdToolName == 'skill_unload') &&
            nativeId == 'SKILL') {
          final bool isUnload = tdToolName == 'skill_unload';
          final SkillEventDetail? detail =
              SkillEventDetail.fromToolUseStartPayload(
                data,
                isUnload: isUnload,
              );
          if (detail != null) {
            final PupauMessage skillMsg = PupauMessage(
              id: data['id']?.toString() ?? '',
              answer: '',
              assistantId:
                  (data['chatBotId'] ?? data['marketplaceId'])?.toString() ??
                  '',
              assistantType: data['marketplaceId'] != null
                  ? AssistantType.marketplace
                  : AssistantType.assistant,
              createdAt: DateTime.now(),
              status: MessageStatus.received,
              sourceType: SourceType.event,
              type: isUnload
                  ? MessageType.skillUnloaded
                  : MessageType.skillLoaded,
              skillEventDetail: detail,
            );
            handleSkillSseEvent(skillMsg);
            return;
          }
        }
      }
    }
    _applyActiveStreamingGroupId(newMessage);
    if (newMessage.type == MessageType.heartbeat ||
        newMessage.type == MessageType.toolHeartbeat ||
        (newMessage.sourceType == SourceType.event &&
            newMessage.type == null)) {
      return;
    }
    if (activeToolLoadings.isEmpty) resetLoadingMessage();
    final PupauMessage? pendingUserMessage = messages.firstWhereOrNull(
      (PupauMessage message) => message.status == MessageStatus.sent,
    );
    if (pendingUserMessage != null) {
      _applyActiveStreamingGroupId(pendingUserMessage);
    }
    messages.refresh();
    update();

    // Track first token received (not heartbeat or empty messages)
    if (!_hasReceivedFirstToken && _currentMessageStartTime != null) {
      _hasReceivedFirstToken = true;
      final int timeToFirstToken = DateTime.now()
          .difference(_currentMessageStartTime!)
          .inMilliseconds;
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.timeToFirstToken,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "timeToFirstToken": timeToFirstToken,
          },
        ),
      );
    }

    // Calculate tokens per second when contextInfo is received
    if (newMessage.contextInfo != null && _currentMessageStartTime != null) {
      final int totalSeconds = DateTime.now()
          .difference(_currentMessageStartTime!)
          .inSeconds;
      if (totalSeconds > 0 && newMessage.contextInfo!.outputTokens > 0) {
        final double tokensPerSecond =
            newMessage.contextInfo!.outputTokens / totalSeconds;
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.tokensPerSecond,
            payload: {
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "tokensPerSecond": tokensPerSecond,
            },
          ),
        );
      }
    }
    if (newMessage.sourceType == SourceType.toolUse) {
      // Skill load/unload tool calls are represented by the chip bubble only —
      // suppress the generic tool use card so it doesn't appear alongside it.
      final dynamic td = data['typeDetails'];
      if (td is Map) {
        final String tdName = (td['toolName']?.toString() ?? '')
            .toLowerCase()
            .trim();
        final String nativeId = (td['nativeTool']?['id']?.toString() ?? '')
            .toUpperCase();
        if ((tdName == 'skill_load' || tdName == 'skill_unload') &&
            nativeId == 'SKILL') {
          return;
        }
      }
      handleToolUseCompletionByMessage(newMessage);
      handleToolUseMessage(data);
      return;
    }
    if (newMessage.sourceType == SourceType.uiTool) {
      handleUiToolMessage(data);
      return;
    }
    if (newMessage.type == MessageType.attachmentTrimming) {
      handleAttachmentTrimmingEvent(data);
      return;
    }
    if (newMessage.type == MessageType.kb) {
      handleKbMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.memory) {
      handleMemoryMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.conversationTitleGenerated) {
      updateConversationTitle(newMessage.title ?? "");
      return;
    }
    if (newMessage.type == MessageType.layerMessage) {
      handleLayerMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.toolUseStart ||
        newMessage.type == MessageType.toolPending) {
      handleToolUseStartPendingMessage(newMessage, data);
      return;
    }
    if (newMessage.type == MessageType.toolArgsDelta) {
      handleToolArgsDeltaEvent(data);
      return;
    }
    if (newMessage.type == MessageType.toolHeartbeat) {
      handleToolHeartbeatEvent(data);
      return;
    }
    if (newMessage.type == MessageType.toolPartialResult) {
      handleToolPartialResultEvent(data);
      return;
    }
    if (newMessage.type == MessageType.webSearchQuery) {
      handleWebSearchQueryMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.audioInputTranscription) {
      handleAudioInputTranscription(newMessage);
      return;
    }
    if (newMessage.type == MessageType.toolEvaluation) {
      handleToolEvaluationMessage();
      return;
    }
    if (newMessage.type == MessageType.groundingVerification) {
      applyGroundingVerification(GroundingVerificationFrame.fromJson(data));
      return;
    }
    if (newMessage.type == MessageType.layerResponse ||
        newMessage.type == MessageType.webSearch ||
        newMessage.type == MessageType.retry) {
      return;
    }
    if (newMessage.sourceType == SourceType.llm &&
        (memoryReferencesBackup.isNotEmpty ||
            alwaysMemoriesBackup.isNotEmpty)) {
      addMemoryBackupToMessage(newMessage);
    }
    // `handleKbMessage`'s own forward-fill (§addKbBackupToMessage) only
    // fires when a *second* `kb`-type frame arrives in the same turn, which
    // is rare — the common case (one `kb` frame, then the LLM answer starts
    // streaming) never hit it, so `kbReferences`/live IMPLICIT
    // `groundingSources` silently never reached the visible message in live
    // SSE mode (history reload worked fine since it reads the persisted
    // `extraInfo.kbReferences` directly, a different code path). Both must
    // reach the *first* real LLM row generically, same as memory above.
    if (newMessage.sourceType == SourceType.llm &&
        kbReferencesBackup.isNotEmpty) {
      addKbBackupToMessage(newMessage);
    }
    if (newMessage.sourceType == SourceType.llm &&
        groundingSourcesBackup.isNotEmpty) {
      addGroundingSourcesBackupToMessage(newMessage);
    }
    bool messageIsEmpty = newMessage.answer == "";
    PupauMessage updatedMessage = updateSSEMessages(newMessage);
    if (!messageIsEmpty) {
      messageNotifier.addData(updatedMessage.answer, updatedMessage.id);
    }
    MessageService.checkSSEErrors(newMessage);
    if (MessageService.canEnableExternalSearch(newMessage, isExternalSearch)) {
      setExternalSearchButton(true);
    }
    if (newMessage.isLast == true) {
      assistantsReplying.value--;
      manageSendSuccess(isExternalSearch);
      _activeStreamingGroupId = null;
      _maybeScheduleGroundingRefetch(updatedMessage);
    }
  }

  /// Applies a verification result (§3.1/§3.3) — either the live
  /// `grounding_verification` frame or the reconnect catch-up
  /// `grounding_verified` event, both funneled through the same
  /// [GroundingVerificationFrame] shape. Idempotent / last-write-wins,
  /// keyed on `queryId`, and also propagated to any sibling rows in the
  /// same `queryGroupId` that already share this turn's `grounding`.
  void applyGroundingVerification(GroundingVerificationFrame frame) {
    if (frame.queryId.isEmpty) return;
    final PupauMessage? target = messages.firstWhereOrNull(
      (PupauMessage m) => m.id == frame.queryId,
    );
    if (target == null) return;
    final GroundingInfo base =
        target.grounding ?? GroundingInfo(queryId: frame.queryId);
    target.grounding = base.withVerification(frame);
    final String groupId = target.groupId;
    if (groupId.isNotEmpty) {
      backfillGroupGrounding(
        messages.where((PupauMessage m) => m.groupId == groupId).toList(),
      );
    }
    messages.refresh();
    update();
  }

  /// Safety cap on §_scheduleGroundingRefetch's poll loop — verification
  /// normally resolves within seconds (live frame: 1-3s, cap 8s per spec
  /// §3.1), so ~5 minutes of retrying is generous headroom for a slow
  /// backend without polling a genuinely stuck one forever.
  static const int _maxGroundingPollAttempts = 30;

  /// §1.2: after `last:true`, if the turn's text carries at least one `[n]`
  /// marker, fetch the authoritative `grounding` block ~3s later (debounced).
  /// No markers ⇒ skip entirely, so ordinary (non-grounded) turns never pay
  /// for this call — keeps the feature "additive and invisible" when unused.
  void _maybeScheduleGroundingRefetch(PupauMessage message) {
    if (!citationMarkerRegex.hasMatch(message.answer)) return;
    _scheduleGroundingRefetch(
      message,
      delay: const Duration(seconds: 3),
      attempt: 1,
    );
  }

  /// Fetches `grounding` and backfills it across the turn's `queryGroupId`
  /// (§1.1/§5). If the result is still `PENDING` (verification hasn't
  /// finished) — or the fetch itself transiently failed — reschedules itself
  /// every 10s until the status resolves or [_maxGroundingPollAttempts] is
  /// hit, so a `CITATIONS_VERIFIED` turn can never get stuck showing
  /// "Verifying…" forever just because the single one-shot refetch landed
  /// too early.
  void _scheduleGroundingRefetch(
    PupauMessage message, {
    required Duration delay,
    required int attempt,
  }) {
    _groundingRefetchTimer?.cancel();
    _groundingRefetchTimer = Timer(delay, () async {
      final GroundingInfo? grounding = await GroundingService.refetchQueryGrounding(
        message.id,
      );
      if (grounding != null) {
        message.grounding = grounding;
        final String groupId = message.groupId;
        if (groupId.isNotEmpty) {
          backfillGroupGrounding(
            messages.where((PupauMessage m) => m.groupId == groupId).toList(),
          );
        }
        messages.refresh();
        update();
      }
      final bool stillPending =
          grounding?.verificationStatus == GroundingVerificationStatus.pending;
      if ((grounding == null || stillPending) &&
          attempt < _maxGroundingPollAttempts) {
        _scheduleGroundingRefetch(
          message,
          delay: const Duration(seconds: 10),
          attempt: attempt + 1,
        );
      }
    });
  }

  void rebuildConversationSkillsFromHistory() {
    SkillsService.applyLatestSnapshotFromMessages(
      messages,
      conversationActiveSkills,
    );
    conversationActiveSkills.refresh();
    update();
  }

  void handleSkillSseEvent(PupauMessage message) {
    final SkillEventDetail? detail = message.skillEventDetail;
    if (detail == null) return;
    final String hash = detail.info.hashId;
    if (detail.isUnload) {
      conversationActiveSkills.remove(hash);
    } else {
      conversationActiveSkills[hash] = detail.info;
    }
    conversationActiveSkills.refresh();
    final String id = message.id.trim().isNotEmpty
        ? message.id
        : 'skill_${hash}_${DateTime.now().microsecondsSinceEpoch}';

    final PupauMessage skillMessage = PupauMessage(
      id: "${id}_skill",
      answer: '',
      assistantId: assistantId,
      assistantType: assistant.value?.type ?? AssistantType.assistant,
      createdAt: DateTime.now(),
      status: MessageStatus.received,
      sourceType: SourceType.event,
      type: message.type,
      skillEventDetail: detail,
    );
    _applyActiveStreamingGroupId(skillMessage);
    addMessage(skillMessage, bypassCheck: true);
    update();
  }

  void handleToolUseStartPendingMessage(
    PupauMessage message,
    Map<String, dynamic> data,
  ) {
    // Prefer `actorType` tool type whenever present.
    final ToolUsePendingData pending = ToolUsePendingData.fromJson(data);
    if (pending.toolName.trim().isNotEmpty) {
      message.toolName = pending.toolName;
    }
    if (pending.toolUseType != ToolUseType.nativeToolsGeneric) {
      message.toolUseType = pending.toolUseType;
    }
    if (message.showTool == false && message.toolMessage != null) {
      loadingMessage.value = LoadingMessage(
        message: message.toolMessage ?? "",
        loadingType: LoadingType.text,
      );
      update();
      return;
    }
    if (message.toolUseType == ToolUseType.nativeToolsBrowserUse) {
      loadingMessage.value = LoadingMessage(
        message: message.toolName ?? "",
        loadingType: LoadingType.browserUse,
      );
      update();
      return;
    }
    if (message.toolUseAgent != null) {
      loadingMessage.value = LoadingMessage(
        message: "@${message.toolUseAgent!.name}",
        loadingType: LoadingType.tag,
      );
      update();
      return;
    }
    if (message.sourceType == SourceType.event &&
        (message.type == MessageType.toolUseStart ||
            message.type == MessageType.toolPending)) {
      final String name = (message.toolName ?? "").trim();
      if (name.isEmpty) return;
      markToolLoadingStarted(name);
      // TOOL_PENDING means queued; TOOL_USE_START means started. We treat both
      // as "active" until TOOL_USE (source) or TOOL_EVALUATION clear them.
      activeToolLoadings[name] =
          message.toolUseType ?? ToolUseType.nativeToolsGeneric;
      activeToolLoadings.refresh();
      if (message.toolUseType == ToolUseType.nativeToolsAttachment) {
        final dynamic toolArgs = data['typeDetails']?['toolArgs'];
        final String? rich = AttachmentToolLabelService.richLabel(
          name,
          toolArgs is Map ? Map<String, dynamic>.from(toolArgs) : null,
        );
        if (rich != null) {
          attachmentToolLoadingLabels[name] = rich;
          attachmentToolLoadingLabels.refresh();
        }
      }
      update();
      syncLoadingMessageFromActiveTools();
      return;
    }
  }

  /// Remove a single tool from the active loading map based on [message.toolName].
  void handleToolUseCompletionByMessage(PupauMessage message) {
    final String name = (message.toolName ?? "").trim();
    if (name.isEmpty) return;
    if (activeToolLoadings.remove(name) != null) {
      markToolLoadingEnded(name);
      activeToolLoadings.refresh();
      toolPartialStatuses.remove(name);
      toolPartialStatuses.refresh();
      attachmentToolLoadingLabels.remove(name);
      attachmentToolLoadingLabels.refresh();
      update();
      syncLoadingMessageFromActiveTools();
    }
  }

  /// Rich label for an active attachment tool loading bubble, or null if not
  /// known yet (falls back to [AttachmentToolLabelService.genericLabel]).
  String? getAttachmentToolLoadingLabel(String toolName) =>
      attachmentToolLoadingLabels[toolName.trim()];

  /// TOOL_EVALUATION means all tools of the current stream have been resolved.
  /// Clear any remaining tool loadings.
  void handleToolEvaluationMessage() {
    if (activeToolLoadings.isEmpty) {
      resetLoadingMessage();
      return;
    }
    activeToolLoadings.clear();
    activeToolLoadings.refresh();
    toolPartialStatuses.clear();
    toolPartialStatuses.refresh();
    attachmentToolLoadingLabels.clear();
    attachmentToolLoadingLabels.refresh();
    _loadingToolStartedAt.clear();
    expandedLoadingTools.clear();
    expandedLoadingTools.refresh();
    userToggledLoadingTools.clear();
    userToggledLoadingTools.refresh();
    _stopLoadingToolsTimerIfIdle();
    update();
    resetLoadingMessage();
  }

  void handleToolArgsDeltaEvent(Map<String, dynamic> data) {
    try {
      final ToolUseArgsDeltaData event = ToolUseArgsDeltaData.fromJson(data);
      final String toolId = event.toolId.trim();
      final String toolName = event.toolName.trim();
      if (toolId.isEmpty || toolName.isEmpty) return;
      markToolLoadingStarted(toolName);

      // Track this tool as "active" (we're between TOOL_PENDING and TOOL_USE_START).
      activeToolLoadings[toolName] = event.toolUseType;
      activeToolLoadings.refresh();

      // Append delta to buffer.
      final ToolArgsDeltaComputation computation =
          ToolArgsDeltaService.computePreview(
            previousBuffer: _toolArgsDeltaBuffers[toolId] ?? '',
            argsDelta: event.argsDelta,
          );
      _toolArgsDeltaBuffers[toolId] = computation.fullBuffer;
      toolArgsPreviewToolIdByName[toolName] = toolId;
      toolArgsPreviewToolIdByName.refresh();

      if (computation.preview != null &&
          computation.preview!.trim().isNotEmpty) {
        toolArgsPreviewContentsById[toolId] = computation.preview!;
        toolArgsPreviewContentsById.refresh();
      }
      if (computation.title != null && computation.title!.trim().isNotEmpty) {
        toolArgsPreviewTitlesById[toolId] = computation.title!.trim();
        toolArgsPreviewTitlesById.refresh();
      }
      update();
      syncLoadingMessageFromActiveTools();
    } catch (_) {
      return;
    }
  }

  bool hasToolArgsPreview(String toolName) =>
      ToolArgsDeltaService.hasPreviewForToolName(
        toolName: toolName,
        toolIdByName: toolArgsPreviewToolIdByName,
        previewsById: toolArgsPreviewContentsById,
        rawBuffersById: _toolArgsDeltaBuffers,
      );

  bool hasToolArgsPreviewByToolId(String toolId) {
    final String normalizedToolId = toolId.trim();
    if (normalizedToolId.isEmpty) return false;
    return ToolArgsDeltaService.hasPreview(
      toolId: normalizedToolId,
      previewsById: toolArgsPreviewContentsById,
      rawBuffersById: _toolArgsDeltaBuffers,
    );
  }

  String getToolArgsPreviewContentByToolId(String toolId) =>
      ToolArgsDeltaService.getPreviewContent(
        toolId: toolId,
        previewsById: toolArgsPreviewContentsById,
        rawBuffersById: _toolArgsDeltaBuffers,
      );

  String getToolArgsPreviewTitleByToolId(String toolId) =>
      ToolArgsDeltaService.getPreviewTitle(
        toolId: toolId,
        titlesById: toolArgsPreviewTitlesById,
      );

  // Tool args delta previews are rendered inline in loading tool bubbles.

  void handleToolHeartbeatEvent(Map<String, dynamic> data) {
    try {
      final ToolUseHeartbeatData event = ToolUseHeartbeatData.fromJson(data);
      final String toolName = event.toolName.trim();
      if (toolName.isEmpty) return;
      markToolLoadingStarted(toolName);
      if (event.toolUseType != ToolUseType.nativeToolsGeneric) {
        activeToolLoadings[toolName] = event.toolUseType;
      }
      activeToolLoadings.refresh();
      update();
      syncLoadingMessageFromActiveTools();
    } catch (_) {
      return;
    }
  }

  /// Handle TOOL_PARTIAL_RESULT events for tools that emit intermediate
  /// phases (currently document_create/document_update).
  void handleToolPartialResultEvent(Map<String, dynamic> data) {
    try {
      final ToolUsePartialResultData event = ToolUsePartialResultData.fromJson(
        data,
      );
      if (event.toolName.isEmpty || event.phase.isEmpty) return;
      markToolLoadingStarted(event.toolName);

      String? status;
      switch (event.phase) {
        case "lint":
          status = Strings.toolPhaseLint.tr;
          break;
        case "creating":
          status = Strings.toolPhaseCreating.tr;
          break;
        case "updating":
          status = Strings.toolPhaseUpdating.tr;
          break;
        default:
          break;
      }

      if (status == null) return;

      // Ensure the tool is tracked as active; partial results only happen for
      // tools that are currently running. Default to document icon where type
      // isn't already known.
      activeToolLoadings[event.toolName] = event.toolUseType;
      activeToolLoadings.refresh();
      toolPartialStatuses[event.toolName] = status;
      toolPartialStatuses.refresh();
      update();
      syncLoadingMessageFromActiveTools();
    } catch (_) {
      return;
    }
  }

  /// Update [loadingMessage] from [activeToolLoadings], supporting multiple
  /// concurrent tool loadings.
  void syncLoadingMessageFromActiveTools() {
    if (activeToolLoadings.isEmpty) {
      // Only reset if we were showing tool loadings; other loading types
      // (dots/text/websearch) are managed separately.
      if (loadingMessage.value.loadingType == LoadingType.toolUse) {
        resetLoadingMessage();
      }
      return;
    }

    final entries = activeToolLoadings.entries.toList();
    final List<ToolLoadingEntry> tools = entries.map((e) {
      final String baseName = e.key;
      final String? status = toolPartialStatuses[baseName];
      final String displayName = status == null
          ? baseName
          : "${baseName.replaceAll("_", " ")} – $status";
      return ToolLoadingEntry(name: displayName, key: baseName, type: e.value);
    }).toList();

    // `message` is primarily used as a fallback label; each tool bubble
    // uses its own `ToolLoadingEntry.name`. When multiple tools are active,
    // we avoid joining names so individual bubbles keep their own titles.
    final String displayMessage = tools.length == 1 ? tools.first.name : "";

    final ToolUseType effectiveType = entries.first.value;

    loadingMessage.value = LoadingMessage(
      message: displayMessage,
      loadingType: LoadingType.toolUse,
      toolUseType: effectiveType,
      tools: tools,
    );
    update();
  }

  void handleAudioInputTranscription(PupauMessage newSseMessage) {
    PupauMessage? sentAudioMessage = messages.firstWhereOrNull(
      (message) => message.status == MessageStatus.sent && message.isAudioInput,
    );
    if (sentAudioMessage != null &&
        (newSseMessage.transcription ?? newSseMessage.query)
            .trim()
            .isNotEmpty) {
      sentAudioMessage.query =
          newSseMessage.transcription ?? newSseMessage.query;
      messages.refresh();
      update();
    }
  }

  void handleAttachmentTrimmingEvent(Map<String, dynamic> data) {
    final Map<String, dynamic>? eventData = data["data"] is Map
        ? Map<String, dynamic>.from(data["data"] as Map)
        : null;
    if (eventData == null) return;
    final String? eventType = (data["type"] is String)
        ? (data["type"] as String).toLowerCase()
        : null;
    final bool isEmergency = eventType == "emergency_trimming";
    final AttachmentTrimmingInfo? trimming = isEmergency
        ? AttachmentTrimmingInfo.fromSseDataEmergency(eventData)
        : AttachmentTrimmingInfo.fromSseDataAttachment(eventData);
    if (trimming == null) return;
    PupauMessage? currentMessage;
    final loadingAssistant = messages
        .where(
          (PupauMessage m) =>
              m.isMessageFromAssistant && m.status == MessageStatus.loading,
        )
        .toList();
    if (loadingAssistant.isNotEmpty) {
      currentMessage = loadingAssistant.last;
    }
    if (currentMessage != null) {
      if (isEmergency) {
        currentMessage.emergencyTrimming = trimming;
      } else {
        currentMessage.attachmentTrimming = trimming;
      }
      messages.refresh();
      update();
    }
    final int truncated = trimming.truncatedCount;
    final int removed = trimming.removedCount;
    final String detail = truncated > 0 && removed > 0
        ? Strings.attachmentTrimmingDetailBoth.trParams({
            'truncated': truncated.toString(),
            'removed': removed.toString(),
          })
        : truncated > 0
        ? Strings.attachmentTrimmingDetailTruncated.trParams({
            'truncated': truncated.toString(),
          })
        : Strings.attachmentTrimmingDetailRemoved.trParams({
            'removed': removed.toString(),
          });
    showFeedbackSnackbar(
      "${Strings.attachmentTrimmingSnackbar.tr} $detail",
      Symbols.content_cut,
      isInfo: true,
    );
  }

  void handleWebSearchQueryMessage(PupauMessage message) {
    loadingMessage.value = LoadingMessage(
      message:
          "${Strings.searchingTheWeb.tr}: \"${message.websearchQuery ?? loadingMessage.value}\"",
      loadingType: LoadingType.webSearch,
    );
    currentWebSearchType.value = message.webSearchType;
    messages.refresh();
    update();
  }

  void handleLayerMessage(PupauMessage message) {
    if (message.answer.trim() != "") {
      loadingMessage.value = LoadingMessage(
        message: message.answer,
        loadingType: LoadingType.text,
      );
      update();
    }
  }

  void handleToolUseMessage(Map<String, dynamic> data) {
    ToolUseMessage toolUseMessage = ToolUseMessage.fromJsonSSE(data);
    bool isPipeline = toolUseMessage.type == ToolUseType.pipeline;
    bool isRemoteCall = toolUseMessage.type == ToolUseType.remoteCall;
    bool isDocument = toolUseMessage.type == ToolUseType.nativeToolsDocument;
    PupauMessage message = PupauMessage(
      id: toolUseMessage.id,
      answer: isPipeline
          ? toolUseMessage.pipelineData?.message ?? ""
          : isRemoteCall
          ? toolUseMessage.remoteCallData?.toString() ?? ""
          : data.toString(),
      type: null,
      sourceType: SourceType.toolUse,
      assistantType: toolUseMessage.chatBotId != null
          ? AssistantType.assistant
          : AssistantType.marketplace,
      isLast: true,
      kbReferences: [],
      urls: [],
      toolUseMessage: toolUseMessage,
      assistantId: '',
      createdAt: DateTime.now(),
      status: MessageStatus.loading,
    );
    _applyActiveStreamingGroupId(message);
    updateSSEMessages(message);
    if (message.answer.trim() != "") {
      messageNotifier.addData(message.answer, message.id);
    }
    if (isDocument) {
      conversation.value != null
          ? Get.find<PupauAttachmentsController>().loadAttachments()
          : Get.find<PupauAttachmentsController>().clearAttachments();
    }
  }

  void handleKbMessage(PupauMessage message) {
    bool isFirstLlmMessage =
        incomingMessages.firstWhereOrNull(
          (PupauMessage message) =>
              message.sourceType == SourceType.llm &&
              message.type != MessageType.kb,
        ) ==
        null;
    if (isFirstLlmMessage) {
      kbReferencesBackup = message.kbReferences;
      groundingSourcesBackup = message.liveGroundingSources;
    } else {
      if (kbReferencesBackup.isNotEmpty) addKbBackupToMessage(message);
      if (groundingSourcesBackup.isNotEmpty) {
        addGroundingSourcesBackupToMessage(message);
      }
      updateSSEMessages(message);
    }
  }

  void handleMemoryMessage(PupauMessage message) {
    final bool hasAny =
        message.memoryReferences.isNotEmpty ||
        message.alwaysMemories.isNotEmpty;
    if (!hasAny) return;
    final bool isFirstLlmMessage =
        incomingMessages.firstWhereOrNull(
          (PupauMessage m) =>
              m.sourceType == SourceType.llm &&
              m.type != MessageType.kb &&
              m.type != MessageType.memory,
        ) ==
        null;
    if (isFirstLlmMessage) {
      memoryReferencesBackup = message.memoryReferences;
      alwaysMemoriesBackup = message.alwaysMemories;
    } else {
      if (memoryReferencesBackup.isNotEmpty ||
          alwaysMemoriesBackup.isNotEmpty) {
        addMemoryBackupToMessage(message);
      }
      updateSSEMessages(message);
    }
  }

  void addMemoryBackupToMessage(PupauMessage message) {
    if (message.sourceType != SourceType.llm) return;
    if (alwaysMemoriesBackup.isNotEmpty) {
      message.alwaysMemories = List<MemoryAlways>.from(message.alwaysMemories);
      message.alwaysMemories.addAll(alwaysMemoriesBackup);
      alwaysMemoriesBackup = <MemoryAlways>[];
    }
    if (memoryReferencesBackup.isNotEmpty) {
      message.memoryReferences = List<MemoryReference>.from(
        message.memoryReferences,
      );
      message.memoryReferences.addAll(memoryReferencesBackup);
      memoryReferencesBackup = <MemoryReference>[];
    }
  }

  void addKbBackupToMessage(PupauMessage message) {
    if (message.sourceType == SourceType.llm && kbReferencesBackup.isNotEmpty) {
      // Ensure kbReferences is a mutable list by creating a copy
      message.kbReferences = List<KbReference>.from(message.kbReferences);
      message.kbReferences.addAll(kbReferencesBackup);
      kbReferencesBackup = [];
    }
  }

  void addGroundingSourcesBackupToMessage(PupauMessage message) {
    if (message.sourceType == SourceType.llm &&
        groundingSourcesBackup.isNotEmpty) {
      message.grounding = GroundingInfo.liveSourcesOnly(
        groundingSourcesBackup,
      ).withQueryId(message.id);
      groundingSourcesBackup = <GroundingSource>[];
    }
  }

  PupauMessage updateSSEMessages(PupauMessage newSseMessage) {
    _applyActiveStreamingGroupId(newSseMessage);
    PupauMessage? sseMessage = incomingMessages.firstWhereOrNull(
      (PupauMessage message) => message.id == newSseMessage.id,
    );
    if (sseMessage == null) {
      // Only "switch" the visible streaming message when the new SSE id has
      // something to render. This avoids replacing content with empty frames.
      if (!_hasRenderableStreamingContent(newSseMessage)) return newSseMessage;
      incomingMessages.add(newSseMessage);
      addMessage(newSseMessage);
      _syncInlineThinkingSiblingMessage(newSseMessage);
      messages.refresh();
      update();
      return newSseMessage;
    } else {
      sseMessage.mergeWith(newSseMessage);
      _syncInlineThinkingSiblingMessage(sseMessage);
      messages.refresh();
      update();
      return sseMessage;
    }
  }

  void manageSendSuccess(bool isExternalSearch) async {
    isStreaming.value = assistantsReplying.value > 0;

    // Calculate time to complete when streaming finishes
    if (!isStreaming.value && _currentMessageStartTime != null) {
      setDefaultMessageInputFieldHeight();
      final timeToComplete = DateTime.now()
          .difference(_currentMessageStartTime!)
          .inMilliseconds;
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.timeToComplete,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "timeToComplete": timeToComplete,
          },
        ),
      );

      // Track first message complete - check if this is the first user message in the conversation
      // (messages.length == 1 means only the initial assistant message exists)
      if (_isFirstMessage && messages.length <= 2) {
        _isFirstMessage = false;
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.firstMessageComplete,
            payload: {
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversationId": conversation.value?.id ?? "",
            },
          ),
        );
      }

      _currentMessageStartTime = null;
      _hasReceivedFirstToken = false;
    }

    for (PupauMessage sseMessage in incomingMessages) {
      PupauMessage? assistantMessage = messages.firstWhereOrNull(
        (PupauMessage message) =>
            message.id == sseMessage.id && message.status != MessageStatus.sent,
      );
      if (assistantMessage != null) {
        assistantMessage.status = MessageStatus.received;
        assistantMessage.createdAt = DateTime.now();
        assistantMessage.isExternalSearch = isExternalSearch;
        assistantMessage.answer = sseMessage.answer;
        _refreshInlineThinkingSiblingsForParent(assistantMessage);
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.messageReceived,
            payload: {
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversationId": conversation.value?.id ?? "",
              "messageId": assistantMessage.id,
            },
          ),
        );
      }
    }
    if (!isStreaming.value) {
      _syncAllInlineThinkingMessages();
      clearEmptyMessages();
      resetLoadingMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        manageChatAutoScroll();
        await Future.delayed(Duration(milliseconds: 250));
        manageChatAutoScroll();
      });
    }
    messages.refresh();
    update();
  }

  void updateConversationTitle(String title) {
    try {
      conversation.value?.title = title;
      conversation.value?.hasTempTitle = false;
      conversation.refresh();
      update();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.conversationTitleGenerated,
          payload: {
            "conversationTitle": title,
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "conversationId": conversation.value?.id ?? "",
          },
        ),
      );
    } catch (e) {
      return;
    }
  }

  /// Clears [chatExtraBottomPaddingActive] when switching conversations / resetting chat.
  void resetExtraBottomScrollPadding() {
    chatExtraBottomPaddingActive.value = false;
    latestQueryAssistantClusterHeight.value = 0.0;
  }

  /// Updates measured assistant cluster height for dynamic bottom slack ([MessagesList]).
  void setLatestQueryAssistantClusterHeight(double heightPx) {
    if (!chatExtraBottomPaddingActive.value) {
      return;
    }
    latestQueryAssistantClusterHeight.value = heightPx.clamp(
      0.0,
      double.infinity,
    );
  }

  void manageChatAutoScroll() {
    if (messages.firstOrNull?.status == MessageStatus.sent) return;
    if (!chatScrollController.hasClients) return;
    if (autoScrollSuspendedByUser || !autoScrollEnabled) return;
    scrollToBottomChat(
      withAnimation: true,
      minDistance: _magnetFollowMinDistancePx,
    );
  }

  void addMessage(PupauMessage message, {bool bypassCheck = false}) {
    String? notifierConversationId = messageNotifier.conversationId;
    String? notifierAssistantId = messageNotifier.assistantId;
    if (bypassCheck ||
        (conversation.value != null &&
            notifierConversationId == conversation.value?.id &&
            notifierAssistantId == assistantId)) {
      messages.insert(0, message);
      messages.refresh();
      update();
    }
  }

  void setExternalSearchButton(bool isVisible) {
    externalSearchVisible.value = isVisible;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      update();
    });
  }

  /// Sends a stop request to the backend and waits for confirmation before
  /// finalizing the cancel locally.
  ///
  /// Flow:
  /// 1. Block re-entry (UI also gates the button on [isStopping]).
  /// 2. Cancel the local SSE stream immediately so no more chunks arrive while
  ///    the user is waiting for the backend acknowledgement.
  /// 3. Await [stopExecution] (POST to the server's stop endpoint).
  /// 4. On success: run the regular cancel flow ([manageCancelAndErrorMessage] +
  ///    [UpdateConversationType.stopMessage] event) and show a feedback snackbar.
  /// 5. On failure (or unavailable endpoint): reload the conversation from the
  ///    server so the local state matches whatever the backend actually has.
  Future<void> sendCancel() async {
    if (isStopping.value || messageSendStream == null) return;
    isStopping.value = true;
    update();
    await messageSendStream!.cancel();
    messageSendStream = null;

    bool success = false;
    if (conversation.value != null) {
      try {
        success = await stopExecution();
      } catch (_) {
        success = false;
      }
    }

    if (success) {
      manageCancelAndErrorMessage();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.stopMessage,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "conversationId": conversation.value?.id ?? "",
          },
        ),
      );
      showFeedbackSnackbar(
        Strings.conversationStoppedCorrectly.tr,
        Symbols.stop_circle,
      );
    } else {
      final String? conversationId = conversation.value?.id;
      if (conversationId != null && conversationId.isNotEmpty) {
        loadConversation(conversationId);
      } else {
        manageCancelAndErrorMessage();
      }
    }

    isStopping.value = false;
    update();
  }

  /// Stops the server-side async run for the current conversation (if any).
  ///
  /// Returns `false` when the endpoint isn't available (e.g. async query
  /// execution flag disabled on the server, typically 404).
  Future<bool> stopExecution() async {
    if (conversation.value == null) return false;
    try {
      final String convId = conversation.value!.id;
      final String convToken = conversation.value!.token;
      final String url = ApiUrls.stopConversationRunUrl(
        assistantId,
        convId,
        isMarketplace: isMarketplace,
      );

      bool success = false;
      await ApiService.call(
        url,
        RequestType.post,
        headers: {"Conversation-Token": convToken},
        onSuccess: (response) => success = true,
      );
      return success;
    } catch (_) {
      return false;
    }
  }

  void manageCancelAndErrorMessage() {
    isStreaming.value = false;
    _activeStreamingGroupId = null;
    setDefaultMessageInputFieldHeight();
    PupauMessage? userMessage = messages.firstWhereOrNull(
      (message) => message.status == MessageStatus.sent,
    );
    userMessage?.isCancelled = true;
    final String groupId = userMessage?.groupId.trim() ?? "";
    PupauMessage? assistantMessage = groupId.isEmpty
        ? null
        : messages.firstWhereOrNull(
            (PupauMessage message) =>
                message.status != MessageStatus.sent &&
                message.groupId.trim() == groupId &&
                message.sourceType == SourceType.llm,
          );
    if (assistantMessage != null) {
      assistantMessage.status = MessageStatus.received;
      assistantMessage.isCancelled = true;
      assistantMessage.createdAt = DateTime.now();
      assistantMessage.answer =
          messageNotifier.messages
              .firstWhereOrNull(
                (NotifierMessage notifierMessage) =>
                    notifierMessage.idMessage == assistantMessage.id,
              )
              ?.message ??
          "";
    }
    resetLoadingMessage();
    clearEmptyMessages();
    messages.refresh();
    update();
  }

  void manageNoVisionCapability() {
    PupauMessage? assistantMessage = messages.firstOrNull;
    if (assistantMessage == null) return;
    assistantMessage.answer =
        ConversationService.getNoVisionCapabilityMessage();
    assistantMessage.status = MessageStatus.received;
    messages.refresh();
    assistantsReplying.value--;
    manageSendSuccess(false);
    update();
  }

  bool stopIsActive() => isStreaming.value;

  bool sendIsActive() =>
      !isStreaming.value &&
      !isStopping.value &&
      inputMessage.value.trim() != "";

  bool isLoadingMessageActive() =>
      // Normal streaming / tool-use / thinking loading states
      (isStreaming.value &&
          (messages.firstOrNull?.status == MessageStatus.sent ||
              messages.firstOrNull?.answer.trim() == "" ||
              // With a tool use bubble as the newest message while streaming:
              // - If tools are still pending, show the tool loading UI (from
              //   [loadingMessage]).
              // - When [activeToolLoadings] is empty, [syncLoadingMessageFromActiveTools]
              //   resets to dots; keep the placeholder visible so default dots
              //   show while waiting for the assistant's next tokens — but do
              //   not show when [loadingType] is still toolUse with an empty map
              //   (that was the one-frame overlap with the bubble).
              // Reading both [activeToolLoadings] and [loadingMessage] here keeps
              // the Obx wired to both reactives.
              (messages.firstOrNull?.toolUseMessage != null &&
                  (activeToolLoadings.isNotEmpty ||
                      loadingMessage.value.loadingType !=
                          LoadingType.toolUse)) ||
              (messages.firstOrNull?.uiToolMessage != null &&
                  hiddenUiToolMessages.contains(
                    messages.firstOrNull?.uiToolMessage?.id,
                  )))) ||
      // Resolving chat entry vs loading a conversation history
      (isChatEntryResolving.value && messages.isEmpty) ||
      (isLoadingConversation.value && messages.isEmpty) ||
      // Waiting for assistant welcome message when there is no conversation yet.
      _isWaitingForWelcomeMessage();

  /// True when we have an assistant selected but its welcome message is still
  /// empty and no conversation has started yet. This is used to show loading
  /// dots while the welcome message is being fetched. Uses [effectiveWelcomeMessage]
  /// so config-provided welcome does not trigger loading.
  bool _isWaitingForWelcomeMessage() {
    if (assistant.value == null) return false;
    if (conversation.value != null) return false;
    if (isStreaming.value ||
        isLoadingConversation.value ||
        isChatEntryResolving.value) {
      return false;
    }
    if (messages.isNotEmpty) return false;
    if (effectiveWelcomeMessage.trim().isNotEmpty) return false;
    return isLoadingAssistant.value;
  }

  void reactMessage(PupauMessage message, Reaction reaction) async {
    if (conversation.value == null) return;
    Reaction oldReaction = message.reaction ?? Reaction.none;
    message.reaction = reaction;
    messages.refresh();
    update();
    String url = ApiUrls.queryUrl(
      assistantId,
      conversation.value!.id,
      message.id,
      isMarketplace: isMarketplace,
    );
    await ApiService.call(
      url,
      RequestType.patch,
      data: {"reaction": ConversationService.getReactionString(reaction)},
      onSuccess: (response) {
        if (reaction != Reaction.none) {
          showFeedbackSnackbar(
            Strings.thanksFeedback.tr,
            Symbols.emoji_emotions,
          );
        }
      },
      onError: (error) {
        showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.checkConnectionOrRetry.tr}",
        );
        message.reaction = oldReaction;
        messages.refresh();
        update();
      },
    );
  }

  void reportMessage(PupauMessage message) async {
    if (conversation.value == null) return;
    String url = ApiUrls.queryUrl(
      assistantId,
      conversation.value!.id,
      message.id,
      isMarketplace: isMarketplace,
    );
    await ApiService.call(
      "$url/report",
      RequestType.post,
      data: {"answer": message.answer},
      onSuccess: (response) {},
    );
    showFeedbackSnackbar(Strings.reportFeedback.tr, Symbols.report_problem);
  }

  //CONVERSATIONS

  Future<void> loadConversation(String conversationId) async {
    try {
      resetConversation();
      assistantsReplying.value = 0;
      isStreaming.value = false;
      setDefaultMessageInputFieldHeight();
      incomingMessages.clear();
      conversationSseSubscription?.cancel();
      conversationSseSubscription = null;
      messageNotifier = MessageNotifier();
      isLoadingConversation.value = true;
      loadingMessage.value = LoadingMessage(
        message: "",
        loadingType: LoadingType.dots,
      );
      update();
      conversation.value = await ConversationService.getConversation(
        assistantId,
        conversationId,
        isMarketplace,
      );
      if (conversation.value == null) {
        isLoadingConversation.value = false;
        isConversationHistoryLoaded = false;
        update();
        return;
      }
      Get.find<PupauAttachmentsController>().loadAttachments();

      // Initialize notifier for possible catch-up/live updates.
      messageNotifier.setAssistantId(assistantId);
      messageNotifier.setConversationId(conversation.value!.id);

      // Try async SSE history + catch-up (feature gated on server).
      final String? lastEventId = PupauSharedPreferences.getLastEventId(
        conversation.value?.id ?? "",
      );
      final Stream<SSEModel>? sseStream =
          await SSEService.createConversationSseGetStream(
            assistantId,
            conversation.value!.id,
            conversation.value!.token,
            lastEventId: lastEventId,
            chatController: this,
          );

      if (sseStream == null) {
        // Fallback to previous REST pagination behavior.
        // Initialize pagination so that the newest messages are loaded first.
        _initializeConversationPagination();
        await loadConversationMessages(reset: true);
        if (conversation.value != null && messages.length > 1) {
          _isFirstMessage = false;
        }
        isLoadingConversation.value = false;
        isConversationHistoryLoaded = true;
        update();
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.conversationChanged,
            payload: {
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversation": conversation.value!,
            },
          ),
        );
        setAssistantSettings();
        // Guarantee the slack sliver (chatExtraBottomPaddingActive) is gone
        // before we measure maxScrollExtent, otherwise scroll targets phantom
        // space and visually overshoots past the real last message.
        chatExtraBottomPaddingActive.value = false;
        latestQueryAssistantClusterHeight.value = 0.0;
        update();
        _scrollToTrueBottomOnLoadConversation();
        return;
      }

      // SSE flow: first event is always `history`, then catch-up/live events.
      isConversationHistoryLoaded = false;
      isConversationLastPage = true;
      conversationPage = 0;
      conversationItemsLoaded = 0;
      resetLoadingMessage();
      chatExtraBottomPaddingActive.value = false;
      latestQueryAssistantClusterHeight.value = 0.0;
      update();
      setAssistantSettings();
      _scrollToTrueBottomOnLoadConversation();

      bool historyLoaded = false;
      final Completer<void> historyCompleter = Completer<void>();

      conversationSseSubscription = sseStream.listen(
        (SSEModel sseEvent) async {
          _bumpSseIdleTimer();
          final String? data = sseEvent.data;
          setLastEventId(sseEvent);
          if (sseEvent.event == 'history') {
            if (historyLoaded) return;
            historyLoaded = true;

            messages.clear();
            resetExtraBottomScrollPadding();
            _clearExpandedMessageGroups();
            incomingMessages.clear();

            try {
              final dynamic decoded = jsonDecode(data ?? '[]');
              final List<dynamic> items = decoded is List
                  ? decoded
                  : <dynamic>[];

              // Use the exact same message shaping as REST pagination, so
              // markdown/thinking/tool-use elements render identically.
              final List<PupauMessage> loadedMessages = items
                  .whereType<Map<String, dynamic>>()
                  .map(
                    (Map<String, dynamic> raw) => PupauMessage.fromLoadedChat(
                      Map<String, dynamic>.from(raw),
                    ),
                  )
                  .toList();
              // §1.1/§5: backfill the final row's `grounding` onto earlier
              // rows in the same `queryGroupId` before splitting into
              // user/assistant messages.
              backfillGroupGrounding(loadedMessages);

              for (final PupauMessage loadedMessage in loadedMessages) {
                final PupauMessage userMessage =
                    MessageService.getUserLoadedMessage(loadedMessage);
                final PupauMessage assistantMessage =
                    MessageService.getAssistantLoadedMessage(loadedMessage);
                final String queryGroupId =
                    InlineThinkingMessageService.queryGroupIdFor(
                      assistantMessage,
                    );
                if (queryGroupId.isNotEmpty) {
                  userMessage.groupId = queryGroupId;
                  assistantMessage.groupId = queryGroupId;
                }
                if (isFirstMessageInGroup(queryGroupId)) {
                  messages.insert(0, userMessage);
                }
                messages.insert(0, assistantMessage);
                incomingMessages.add(assistantMessage);
              }
              _syncAllInlineThinkingMessages();
            } catch (_) {
              // If parsing fails, keep whatever was loaded by the resetConversation.
            }

            messages.refresh();
            update();
            rebuildConversationSkillsFromHistory();
            isConversationHistoryLoaded = true;
            isConversationLastPage = true;

            // Only enter streaming mode immediately when history is not empty.
            // If history is empty and no further events arrive, keep non-streaming.
            if (messages.isNotEmpty) {
              assistantsReplying.value = 1;
              isStreaming.value = true;
              _bumpSseIdleTimer();
            } else {
              assistantsReplying.value = 0;
              isStreaming.value = false;
              setDefaultMessageInputFieldHeight();
            }
            update();

            if (!historyCompleter.isCompleted) {
              historyCompleter.complete();
            }
            return;
          }

          if (!historyLoaded) return;
          if (data == null || data.trim().isEmpty) return;

          try {
            final Map<String, dynamic> decoded =
                jsonDecode(data) as Map<String, dynamic>;

            // Async SSE reconnection payloads are wrapped:
            // { eventType: "...", payload: {...}, ... }
            final String eventType = (decoded['eventType']?.toString() ?? '')
                .trim();

            // Terminal async events: stop streaming UI.
            const List<String> terminalTypes = <String>[
              'run_completed',
              'run_stopped',
              'run_error',
            ];
            if (terminalTypes.contains(eventType)) {
              assistantsReplying.value = 0;
              isStreaming.value = false;
              resetLoadingMessage();
              setDefaultMessageInputFieldHeight();
              update();
              return;
            }

            // §3.1 catch-up event: can arrive for a turn that finished long
            // ago (stale reconnect cursor), so it must NOT be treated as
            // "the run is active" like the generic branch below does.
            if (eventType == 'grounding_verified') {
              applyGroundingVerification(
                GroundingVerificationFrame.fromJson(decoded),
              );
              return;
            }

            // Any non-terminal event after history means the run is active.
            // Mirror the regular sendMessage() behavior (assistantsReplying=1).
            if (!isStreaming.value) {
              assistantsReplying.value = 1;
              isStreaming.value = true;
              update();
            }

            if (eventType == 'message') {
              final Map<String, dynamic> payload = decoded['payload'];
              manageSSEData(payload, false);
              return;
            }
          } catch (_) {}
        },
        onError: (e) {
          _cancelSseIdleTimer();
          if (!historyCompleter.isCompleted) {
            historyCompleter.complete();
          }
          showErrorSnackbar(
            "${Strings.apiErrorGeneric.tr} ${Strings.checkConnectionOrRetry.tr}",
          );
        },
        onDone: () {
          _cancelSseIdleTimer();
          // If the run completed/stopped or the server closes the stream,
          // we consider streaming finished.
          assistantsReplying.value = 0;
          isStreaming.value = false;
          resetLoadingMessage();
          setDefaultMessageInputFieldHeight();
          update();
          if (!historyCompleter.isCompleted) {
            historyCompleter.complete();
          }
        },
        cancelOnError: false,
      );

      await historyCompleter.future;

      if (conversation.value != null && messages.length > 1) {
        _isFirstMessage = false;
      }

      isLoadingConversation.value = false;
      isConversationHistoryLoaded = true;
      isConversationLastPage = true;
      chatExtraBottomPaddingActive.value = false;
      latestQueryAssistantClusterHeight.value = 0.0;
      update();
      _scrollToTrueBottomOnLoadConversation();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.conversationChanged,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "conversation": conversation.value!,
          },
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to load conversation: ${e.toString()}';
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": errorMessage,
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "conversationId": conversationId,
          },
        ),
      );
      isLoadingConversation.value = false;
      update();
    }
  }

  Future<void> loadConversationMessages({bool reset = false}) async {
    if (isLoadingConversationPage || isConversationLastPage) {
      return;
    }

    double? previousMaxExtent;
    double? previousPixels;
    if (!reset && chatScrollController.hasClients) {
      previousMaxExtent =
          chatScrollController.positions.lastOrNull?.maxScrollExtent;
      previousPixels = chatScrollController.positions.lastOrNull?.pixels;
    }

    isLoadingConversationPage = true;

    String url = ApiUrls.queriesUrl(
      assistantId,
      conversation.value?.id ?? "",
      page: conversationPage,
      isMarketplace: isMarketplace,
    );

    try {
      await ApiService.call(
        url,
        RequestType.get,
        onSuccess: (response) {
          final int currentPage = conversationPage;
          List<dynamic> items = response.data['items'] ?? [];
          if (items.isNotEmpty) {
            List<PupauMessage> queryList = messagesFromLoadedChat(
              jsonEncode(items),
            );
            // §1.1/§5: the authoritative `grounding` block only lives on the
            // final row of a `queryGroupId` — copy it onto earlier rows in
            // the same group before splitting into user/assistant messages.
            backfillGroupGrounding(queryList);

            // When resetting (initial load), we build the list "from scratch"
            // by inserting at the front so that, after the UI reverses the
            // list, the most recent messages appear at the bottom.
            //
            // When loading older pages (scrolling up), we append at the end so
            // that, after reversal, they appear at the top of the viewport.
            final bool isInitialLoad = reset;

            for (PupauMessage message in queryList) {
              PupauMessage userMessage = MessageService.getUserLoadedMessage(
                message,
              );
              PupauMessage assistantMessage =
                  MessageService.getAssistantLoadedMessage(message);
              final String queryGroupId =
                  InlineThinkingMessageService.queryGroupIdFor(
                    assistantMessage,
                  );
              if (queryGroupId.isNotEmpty) {
                userMessage.groupId = queryGroupId;
                assistantMessage.groupId = queryGroupId;
              }
              if (isInitialLoad) {
                if (isFirstMessageInGroup(queryGroupId)) {
                  messages.insert(0, userMessage);
                }
                messages.insert(0, assistantMessage);
                _syncInlineThinkingSiblingMessage(assistantMessage);
              } else {
                if (isFirstMessageInGroup(queryGroupId)) {
                  messages.add(userMessage);
                }
                messages.add(assistantMessage);
                _syncInlineThinkingSiblingMessage(assistantMessage);
              }
            }
          }
          // Track how many queries have been loaded so far (informational only).
          conversationItemsLoaded += items.length;

          // We consider pagination finished when:
          // - the API returns no items, or
          // - we've just loaded page 0 (the oldest page).
          if (items.isEmpty || currentPage == 0) {
            isConversationLastPage = true;
          } else {
            isConversationLastPage = false;
          }

          // Move to the previous page index (older messages) for the next load,
          // unless we've already reached the oldest page.
          if (!isConversationLastPage && conversationPage > 0) {
            conversationPage--;
          }

          // If the last page (initial load) has very few messages, eagerly
          // load one more older page so the chat isn't almost empty.
          // We only do this on the first (reset) load to avoid chaining
          // multiple extra page requests.
          if (reset && items.length <= 5 && currentPage > 0) {
            // Fire and forget; this call will run with reset = false and
            // append older messages at the top (tail) of the history.
            loadConversationMessages();
          }
          messages.refresh();
          update();
          rebuildConversationSkillsFromHistory();
        },
        onError: (error) {
          update();
        },
      );
    } finally {
      isLoadingConversationPage = false;
      update();
    }

    if (!reset &&
        previousPixels != null &&
        previousMaxExtent != null &&
        chatScrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!chatScrollController.hasClients) return;

        final position = chatScrollController.positions.lastOrNull;
        if (position == null) return;

        double newMax = position.maxScrollExtent;
        double minExtent = position.minScrollExtent;
        double offsetDiff = newMax - previousMaxExtent!;
        double targetOffset = previousPixels! + offsetDiff;

        // Clamp targetOffset to valid bounds first, then apply safety margin to prevent bounce
        // Use a small safety margin (0.5px) to prevent floating point precision issues
        final safetyMargin = 0.5;
        targetOffset = targetOffset.clamp(minExtent, newMax);
        // Apply safety margin to prevent overshoot that causes bounce
        if (targetOffset >= newMax - safetyMargin) {
          targetOffset = newMax - safetyMargin;
        }

        // Use position.jumpTo() which respects physics constraints better
        position.jumpTo(targetOffset);
      });
    }
  }

  void resetConversationPagination() {
    isConversationLastPage = false;
    isLoadingConversationPage = false;
    conversationPage = 0;
    conversationItemsLoaded = 0;
  }

  /// Initializes pagination for a loaded conversation so that the newest
  /// messages are shown first and older messages are fetched as the user
  /// scrolls upwards.
  ///
  /// The backend returns pages in chronological order (page 0 = oldest),
  /// while the chat UI expects to start from the newest page. We therefore
  /// compute the last available page index from `queryCount` and the page
  /// size (20) and start loading from there, moving backwards (page-1)
  /// when older messages are requested.
  void _initializeConversationPagination() {
    isConversationLastPage = false;
    isLoadingConversationPage = false;
    conversationItemsLoaded = 0;

    final int totalQueries = conversation.value?.queryCount ?? 0;
    if (totalQueries <= 0) {
      conversationPage = 0;
      isConversationLastPage = true;
      return;
    }

    const int pageSize = 20;
    final int totalPages = (totalQueries + pageSize - 1) ~/ pageSize;
    // Backend is zero-based: last page index is totalPages - 1.
    conversationPage = totalPages > 0 ? totalPages - 1 : 0;
  }

  // SCROLL MANAGEMENT

  /// Magnet follow only scrolls when farther than this from [maxScrollExtent].
  static const double _magnetFollowMinDistancePx = 8.0;

  double? _chatDistanceFromBottom() {
    if (!chatScrollController.hasClients) return null;
    final ScrollPosition? position = chatScrollController.positions.lastOrNull;
    if (position == null) return null;
    return position.maxScrollExtent - position.pixels;
  }

  bool _isChatWithinMinDistanceOfBottom(double minDistance) {
    final double? distance = _chatDistanceFromBottom();
    if (distance == null) return true;
    return distance <= minDistance;
  }

  void initScrollControllers() {
    chatScrollController.addListener(() {
      const double topDistanceForStatus = 200.0;
      const double topDistanceForPagination = 500.0;
      const double bottomStickinessDefault = 82.0;
      const double bottomStickinessWithSendPadding = 180.0;
      double currentPixels =
          chatScrollController.positions.lastOrNull?.pixels ?? 0;
      final double maxExtent =
          chatScrollController.positions.lastOrNull?.maxScrollExtent ?? 0;
      final double bottomEpsilon = chatExtraBottomPaddingActive.value
          ? bottomStickinessWithSendPadding
          : bottomStickinessDefault;
      bool isTop = currentPixels <= topDistanceForStatus;
      bool isBottom = currentPixels >= maxExtent - bottomEpsilon;
      bool shouldLoadConversationQueries =
          currentPixels <= topDistanceForPagination;
      isAtTop.value = isTop;
      isAtBottom.value = isBottom;

      // Re-enable auto-scroll only when the user is back at bottom and magnet is ON.
      // Otherwise keep it suspended so the user can read older content.
      autoScrollEnabled =
          isBottom &&
          autoScrollMagnetEnabled.value &&
          !autoScrollSuspendedByUser;

      update();
      if (shouldLoadConversationQueries &&
          isConversationHistoryLoaded &&
          !isConversationLastPage &&
          !isLoadingConversationPage &&
          !isLoadingConversation.value &&
          conversation.value != null) {
        loadConversationMessages();
      }
    });
  }

  /// Scroll-to-bottom strategy used exclusively by [loadConversation].
  Future<void> _scrollToTrueBottomOnLoadConversation() async {
    await Future.delayed(const Duration(milliseconds: 80));
    _forceSnapChatScrollToBottom();
    await Future.delayed(const Duration(milliseconds: 200));
    _forceSnapChatScrollToBottom();
  }

  /// Jumps every attached [ScrollPosition] to its current [maxScrollExtent].
  /// Custom scroll views can briefly report a short extent; call again after layout.
  void _forceSnapChatScrollToBottom() {
    if (!chatScrollController.hasClients) return;
    for (final ScrollPosition position in chatScrollController.positions) {
      final double maxExtent = position.maxScrollExtent;
      if (maxExtent > 0.0) {
        position.jumpTo(maxExtent);
      }
    }
  }

  /// Scrolls the chat list to the bottom ([maxScrollExtent]).
  ///
  /// Forces a hard [jumpTo] on every attached position first and after [animateTo],
  /// plus several post-frame and delayed snaps so the offset matches the true extent
  /// after slivers rebuild (streaming, slack animation).
  ///
  /// [minDistance] of `0.0` (default) always scrolls. A positive value skips
  /// scrolling when already within that distance of the bottom.
  void scrollToBottomChat({
    bool withAnimation = false,
    double minDistance = 0.0,
  }) async {
    if (!chatScrollController.hasClients) return;
    final ScrollPosition? initialPosition =
        chatScrollController.positions.lastOrNull;
    if (initialPosition == null || initialPosition.maxScrollExtent <= 0.0) {
      return;
    }
    if (minDistance > 0.0 && _isChatWithinMinDistanceOfBottom(minDistance)) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!chatScrollController.hasClients) return;

    final ScrollPosition? position = chatScrollController.positions.lastOrNull;
    if (position == null) return;

    final double maxScrollExtent = position.maxScrollExtent;
    if (maxScrollExtent <= 0.0) return;

    final double distanceFromBottom = maxScrollExtent - position.pixels;
    if (minDistance > 0.0 && distanceFromBottom <= minDistance) return;

    const double largeScrollThreshold = 1500.0;

    if (withAnimation && distanceFromBottom <= largeScrollThreshold) {
      try {
        await chatScrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } catch (_) {
        if (minDistance > 0.0 &&
            _isChatWithinMinDistanceOfBottom(minDistance)) {
          return;
        }
        _forceSnapChatScrollToBottom();
      }
    } else {
      _forceSnapChatScrollToBottom();
    }
  }

  void scrollToTopChat({bool withAnimation = false}) {
    if (!chatScrollController.hasClients || conversation.value == null) {
      return;
    }

    void performScroll() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!chatScrollController.hasClients) return;

      final position = chatScrollController.positions.lastOrNull;
      if (position == null) return;

      final minScrollExtent = position.minScrollExtent;
      final currentScrollPosition = position.pixels;

      // Don't scroll if there's no content to scroll
      if (minScrollExtent >= currentScrollPosition &&
          currentScrollPosition <= 0) {
        return;
      }

      // Don't scroll if already very close to top (within 50px) to prevent bounce
      const nearTopThreshold = 50.0;
      final distanceFromTop = currentScrollPosition - minScrollExtent;
      if (distanceFromTop <= nearTopThreshold) return;

      final scrollDistance = distanceFromTop.abs();

      // For large scroll distances (>1500px) or when animation is not requested,
      // use jumpTo for instant, lag-free scrolling
      // For small distances with animation requested, use animateTo for smooth UX
      const largeScrollThreshold = 1500.0;

      if (!withAnimation || scrollDistance > largeScrollThreshold) {
        // Instant jump - much faster for large content
        chatScrollController.jumpTo(minScrollExtent);
      } else {
        // Smooth animation only for small scrolls when explicitly requested
        // Use easeInOut to prevent bounce - it smoothly accelerates and decelerates
        chatScrollController.animateTo(
          minScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }

    // Try immediately first
    performScroll();

    // Ensure it happens after layout if needed (for very large content)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      performScroll();
    });
  }

  void scrollToUserMessage(String messageId) async {
    pendingScrollAlignUserMessageId.value = messageId;
    update();
    scrollToBottomChat(withAnimation: true);
    await Future.delayed(const Duration(milliseconds: 250));
    final BuildContext? anchorContext =
        scrollAlignSentUserBubbleKey.currentContext;
    if (anchorContext == null) return;
    Scrollable.ensureVisible(
      // ignore: use_build_context_synchronously
      anchorContext,
      alignment: 0.0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pendingScrollAlignUserMessageId.value = null;
      update();
    });
  }

  /// Suspends auto-scroll without changing the magnet preference.
  void suspendAutoScroll() {
    autoScrollSuspendedByUser = true;
    if (!autoScrollEnabled) {
      update();
      return;
    }
    autoScrollEnabled = false;
    update();
  }

  /// Clears the user suspension so magnet can resume when at bottom.
  void clearAutoScrollSuspension() {
    if (!autoScrollSuspendedByUser) return;
    autoScrollSuspendedByUser = false;
    autoScrollEnabled = isAtBottom.value && autoScrollMagnetEnabled.value;
    update();
  }

  void toggleAutoScrollMagnet() {
    autoScrollMagnetEnabled.value = !autoScrollMagnetEnabled.value;
    // Toggling the magnet doesn't clear a user suspension.
    autoScrollEnabled =
        isAtBottom.value &&
        autoScrollMagnetEnabled.value &&
        !autoScrollSuspendedByUser;
    update();
  }

  //MISC

  void manageMessageContextMenu(int selectedOption, PupauMessage message) {
    switch (selectedOption) {
      case 0: //Like
        if (message.reaction != Reaction.like) {
          reactMessage(message, Reaction.like);
        } else {
          reactMessage(message, Reaction.none);
        }
        break;
      case 1: //Dislike
        if (message.reaction != Reaction.dislike) {
          reactMessage(message, Reaction.dislike);
        } else {
          reactMessage(message, Reaction.none);
        }
        break;
      case 2: //Copy
        Clipboard.setData(
          ClipboardData(
            text: TagService.plainTextForCopy(
              message.isMessageFromAssistant ? message.answer : message.query,
            ),
          ),
        );
        showFeedbackSnackbar(
          Strings.copiedClipboard.tr,
          Symbols.content_copy,
          isInfo: true,
        );
        break;
      case 3: //Use
        inputMessageController.text = message.isMessageFromAssistant
            ? message.answer
            : message.query;
        inputMessage.value = message.isMessageFromAssistant
            ? message.answer
            : message.query;
        messages.refresh();
        update();
        break;
      case 4: //Read
        ttsService.startReading(message, messages, this);
        break;
      case 5: //Fork
        openForkConversationModal(message.id);
        break;
      case 6: //Report
        reportMessage(message);
        break;
      case 7: //Attachment trimming
        showAttachmentTrimmingModalForMessage(message);
        break;
      case 8: //Edit user message (fork from previous + send new text)
        showEditMessageModal(message);
        break;
      case 9: //Memories used
        showMemoryReferencesModal(
          alwaysMemories: message.alwaysMemories,
          references: message.memoryReferences,
        );
        break;
      case 10: //Expand / collapse grouped query row
        toggleMessageGroupExpanded(message.groupId);
        break;
    }
  }

  /// Shows the attachment/emergency trimming modal for an assistant message and marks it as opened.
  void showAttachmentTrimmingModalForMessage(PupauMessage message) {
    final bool hasAttachment = _hasTrimmingContent(message.attachmentTrimming);
    final bool hasEmergency = _hasTrimmingContent(message.emergencyTrimming);
    if (!hasAttachment && !hasEmergency) return;
    final BuildContext? context = Get.context;
    if (context == null) return;
    showAttachmentTrimmingDialog(
      context,
      attachmentTrimming: message.attachmentTrimming,
      emergencyTrimming: message.emergencyTrimming,
      isAnonymous: isAnonymous,
    );
    PupauSharedPreferences.addAttachmentTrimmingOpenedMessageId(message.id);
    attachmentTrimmingOpenedMessageIds.add(message.id);
    attachmentTrimmingOpenedMessageIds.refresh();
    update();
  }

  static bool _hasTrimmingContent(AttachmentTrimmingInfo? info) {
    if (info == null) return false;
    if (!info.applied) return false;
    return info.truncatedCount > 0 ||
        info.removedCount > 0 ||
        info.items.isNotEmpty;
  }

  bool isFirstMessageInGroup(String groupId) =>
      groupId == "" ||
      messages.firstWhereOrNull(
            (PupauMessage message) => message.groupId == groupId,
          ) ==
          null;

  //MENTIONS

  void onMention(String? value) {
    if (!isMentionAvailable.value) return;
    if (value == null) {
      mentionValue.value = "";
      filteredAssistants.value = [];
    } else {
      mentionValue.value = value;
      String searchInput = value.substring(1); //Removes the @
      filteredAssistants.value = assistants
          .where(
            (Assistant assistant) =>
                !taggedAssistants.contains(assistant) &&
                (assistant.name).toLowerCase().trim().contains(
                  searchInput.toLowerCase().trim(),
                ),
          )
          .toList();
    }
    filteredAssistants.refresh();
    update();
  }

  void onMentionTap() {
    mentionValue.value = "";
    filteredAssistants.value = [];
    filteredAssistants.refresh();
    update();
  }

  void addTaggedAssistants() {
    taggedAssistants.addAll(inputMessageController.mentions.cast<Assistant>());
    taggedAssistants.value = taggedAssistants.toSet().toList();
    taggedAssistants.refresh();
    assistantsReplying.value = taggedAssistants.isEmpty
        ? 1
        : taggedAssistants.length;
    update();
  }

  void clearTaggedAssistants() {
    taggedAssistants.clear();
    taggedAssistants.refresh();
    update();
  }

  void removeTaggedAssistant(Assistant assistant) {
    taggedAssistants.remove(assistant);
    taggedAssistants.refresh();
    int removeIndex = inputMessageController.mentions.indexOf(assistant);
    if (removeIndex != -1) inputMessageController.remove(index: removeIndex);
    update();
  }

  //WEB SEARCH

  void toggleWebSearch() {
    isWebSearchActive.value = !isWebSearchActive.value;
    update();
  }

  // THINKING (extended reasoning)

  bool isThinkingSupported() => assistant.value?.supportsThinking ?? false;

  List<String> supportedThinkingEfforts() =>
      assistant.value?.supportedThinkingEfforts ?? const <String>[];

  Future<void> setThinkingEnabled(bool enabled) async {
    thinkingEnabled.value = enabled;
    update();
    final String assistantIdValue = assistant.value?.id ?? "";
    if (assistantIdValue.trim().isNotEmpty && isThinkingSupported()) {
      // Fire-and-forget: persist user preference server-side.
      SettingsService.setUserSettings(
        settings: <Setting>[
          Setting(
            id: Settings.assistantThinkingEnabledId,
            assistantId: assistantIdValue,
            settingValues: <SettingValue>[
              SettingValue(
                settingName: Settings.settingEnableName,
                settingData: enabled,
              ),
            ],
          ),
        ],
        isMarketplace: isMarketplace,
      );
    }
    if (!enabled) return;
    // Ensure we have a valid effort when enabling.
    if (thinkingEffort.value.trim().isEmpty &&
        supportedThinkingEfforts().isNotEmpty) {
      final List<String> efforts = supportedThinkingEfforts();
      thinkingEffort.value = efforts[(efforts.length / 2).floor()];
      final String normalizedEffort = thinkingEffort.value.trim();
      if (assistantIdValue.trim().isNotEmpty &&
          isThinkingSupported() &&
          normalizedEffort.isNotEmpty) {
        SettingsService.setUserSettings(
          settings: <Setting>[
            Setting(
              id: Settings.assistantThinkingEffortId,
              assistantId: assistantIdValue,
              settingValues: <SettingValue>[
                SettingValue(
                  settingName: Settings.assistantThinkingEffortName,
                  settingData: normalizedEffort,
                ),
              ],
            ),
          ],
          isMarketplace: isMarketplace,
        );
      }
    }
  }

  Future<void> setThinkingEffort(String? effort) async {
    final String normalized = (effort ?? "").trim();
    if (normalized.isNotEmpty &&
        supportedThinkingEfforts().isNotEmpty &&
        !supportedThinkingEfforts().contains(normalized)) {
      return;
    }
    thinkingEffort.value = normalized;
    update();
    final String assistantIdValue = assistant.value?.id ?? "";
    if (assistantIdValue.trim().isNotEmpty && isThinkingSupported()) {
      SettingsService.setUserSettings(
        settings: <Setting>[
          Setting(
            id: Settings.assistantThinkingEffortId,
            assistantId: assistantIdValue,
            settingValues: <SettingValue>[
              SettingValue(
                settingName: Settings.assistantThinkingEffortName,
                settingData: normalized.isEmpty ? null : normalized,
              ),
            ],
          ),
        ],
        isMarketplace: isMarketplace,
      );
    }
  }

  /// Returns the effort to send (validated) or null.
  /// Only meaningful when [thinkingEnabled] is true and model supports it.
  String? thinkingEffortToSend() {
    if (!isThinkingSupported() || !thinkingEnabled.value) return null;
    final List<String> efforts = supportedThinkingEfforts();
    if (efforts.isEmpty) return null;
    final String current = thinkingEffort.value.trim();
    if (current.isNotEmpty && efforts.contains(current)) return current;
    return null;
  }

  // NERD STATS

  void setNerdStats(bool value) {
    showNerdStats.value = value;
    update();
  }

  void selectImage(String value, ImageType type) {
    selectedImage.value = ChatImage(value: value, type: type);
    update();
    BuildContext? safeContext = getSafeModalContext();
    if (safeContext == null) return;
    Navigator.push(
      safeContext,
      MaterialPageRoute(builder: (context) => const ChatImageFull()),
    );
  }

  // ANONYMOUS CONVERSATION

  Future<void> setAssistantSettings() async {
    try {
      UsageSettings? usageSettings = assistant.value?.usageSettings;
      if (usageSettings != null) {
        isAttachmentAvailable.value = usageSettings.canAttach;
        isActionBarAlwaysVisible.value = usageSettings.actionBarAlwaysVisible;
        isWebSearchAvailable.value = usageSettings.canWebSearch;
        isMentionAvailable.value = usageSettings.canTag;

        // Thinking preferences are user-scoped settings (from backend usageSettings),
        // while supportsThinking/supportedThinkingEfforts are model capabilities.
        if (!isThinkingSupported()) {
          thinkingEnabled.value = false;
          thinkingEffort.value = "";
        } else {
          getThinkingEffortSettings();
        }
        if ((pupauConfig?.isAnonymous ?? false) &&
            assistant.value?.usageSettings?.canAnonymous == false) {
          PupauEventService.instance.emitPupauEvent(
            PupauEvent(
              type: UpdateConversationType.error,
              payload: {
                "error":
                    "Anonymous conversations are not allowed for this assistant. Please use a different assistant or create a new conversation.",
                "assistantId": assistantId,
                "assistantType":
                    assistant.value?.type ?? AssistantType.assistant,
              },
            ),
          );
          await showCustomBasicDialog(
            Strings.anonymousConversationsNotAllowed.tr,
          );
          manageForceBack();
        }
      }
      List<String> newConversationStarters;
      if (pupauConfig?.conversationStarters.isNotEmpty ?? false) {
        newConversationStarters = List<String>.from(
          pupauConfig?.conversationStarters ?? [],
        );
      } else {
        List<String> chatEngagementPrompts =
            assistant.value?.apiKeyConfig?.chatEngagementPrompts ??
            assistant.value?.usageSettings?.chatEngagementPrompts ??
            <String>[];
        newConversationStarters = chatEngagementPrompts.isNotEmpty
            ? List<String>.from(chatEngagementPrompts)
            : <String>[];
      }
      conversationStarters.value = newConversationStarters;
      conversationStarters.refresh();
      showNerdStats.value = pupauConfig?.showNerdStats ?? false;
      hideInputBox.value = pupauConfig?.hideInputBox ?? false;
      update();
    } catch (e, stackTrace) {
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error in setAssistantSettings: ${e.toString()}",
            "errorType": e.runtimeType.toString(),
            "stackTrace": stackTrace.toString(),
            "assistantId": assistantId,
            "assistantExists": assistant.value != null,
            "usageSettingsExists": assistant.value?.usageSettings != null,
            "apiKeyConfigExists": assistant.value?.apiKeyConfig != null,
          },
        ),
      );
      rethrow;
    }
  }

  void getThinkingEffortSettings() async {
    UsageSettings? usageSettings = assistant.value?.usageSettings;
    final String assistantId = assistant.value?.id ?? "";
    bool? fetchedEnabled;
    String? fetchedEffort;
    if (assistantId.isNotEmpty) {
      try {
        final Map<String, dynamic>? enabledSetting =
            await SettingsService.readUserSettingById(
              settingId: Settings.assistantThinkingEnabledId,
              assistantId: assistantId,
              isMarketplace: isMarketplace,
            );
        fetchedEnabled = enabledSetting?[Settings.settingEnableName];
        final Map<String, dynamic>? effortSetting =
            await SettingsService.readUserSettingById(
              settingId: Settings.assistantThinkingEffortId,
              assistantId: assistantId,
              isMarketplace: isMarketplace,
            );
        fetchedEffort = effortSetting?[Settings.assistantThinkingEffortName];
      } catch (_) {}
    }
    // Prefer user settings from /settings/user. Fallback to usageSettings
    // until backend starts including these fields there.
    thinkingEnabled.value =
        fetchedEnabled ?? usageSettings?.thinkingEnabled ?? false;
    thinkingEffort.value = fetchedEffort ?? usageSettings?.thinkingEffort ?? "";

    if (thinkingEffort.value.isNotEmpty &&
        !supportedThinkingEfforts().contains(thinkingEffort.value)) {
      thinkingEffort.value = "";
    }
    if (thinkingEnabled.value &&
        thinkingEffort.value.isEmpty &&
        supportedThinkingEfforts().isNotEmpty) {
      final List<String> efforts = supportedThinkingEfforts();
      thinkingEffort.value = efforts[(efforts.length / 2).floor()];
    }
    update();
  }

  void manageForceBack() {
    if (widgetMode == WidgetMode.full) {
      BuildContext? safeContext = getSafeModalContext();
      if (safeContext == null) return;
      Navigator.pop(safeContext);
    } else {
      _onCollapseCallback?.call();
    }
  }

  //Fork

  void openForkConversationModal(String messageId) {
    forkMessageId.value = messageId;
    forkConversationTitle.value =
        "${conversation.value?.title ?? Strings.newConversation.tr} (${Strings.copy.tr.toLowerCase()})";
    forkConversationTitleController.text = forkConversationTitle.value;
    update();
    showForkConversationModal();
  }

  Future<void> forkConversation() async {
    if (assistant.value == null || conversation.value == null) return;
    isForking.value = true;
    update();
    try {
      PupauConversation? forkConversation =
          await ConversationService.forkConversation(
            assistantId,
            conversation.value!.id,
            forkConversationTitle.value,
            forkMessageId.value,
            isMarketplace,
          );
      if (forkConversation != null) await loadConversation(forkConversation.id);
      showFeedbackSnackbar(
        Strings.newConversationCreated.tr,
        Symbols.fork_left,
        flipX: true,
        flipY: true,
      );
    } finally {
      isForking.value = false;
      update();
    }
  }

  /// [lastQueryId] for fork: the **previous user** message id (not the assistant
  /// row, not the edited bubble). Resolves the edited row via
  /// [PupauMessage.isMessageFromAssistant] because user/assistant share [PupauMessage.id].
  ///
  /// Returns null when [userMessage] is the first user message in the thread (no
  /// older user to branch after) — caller should start a new conversation instead.
  String? _previousUserMessageIdForEdit(PupauMessage userMessage) {
    try {
      List<PupauMessage> allUserMessages = messages
          .where((m) => m.status == MessageStatus.sent)
          .toList();
      int thisMessageIndex = allUserMessages.indexWhere(
        (m) => m.id == userMessage.id,
      );
      if (thisMessageIndex == -1 ||
          allUserMessages.length <= thisMessageIndex + 1) {
        return null;
      }
      return allUserMessages[thisMessageIndex + 1]
          .id; // +1 Because list is reversed
    } catch (e) {
      return null;
    }
  }

  /// Fork after the previous user query (or new conversation if this was the first
  /// user message), then send [newText].
  Future<void> editUserMessage(PupauMessage message, String newText) async {
    if (assistant.value == null || conversation.value == null) return;
    if (message.isMessageFromAssistant) return;
    final String trimmed = newText.trim();
    if (trimmed.isEmpty) return;

    final String? previousMessageId = _previousUserMessageIdForEdit(message);
    isForking.value = true;
    update();
    try {
      if (previousMessageId == null || previousMessageId.isEmpty) {
        await createNewConversation();
        if (conversation.value == null) {
          showErrorSnackbar(Strings.apiErrorGeneric.tr);
          return;
        }
        await loadConversation(conversation.value!.id);
        assistantsReplying.value = 0;
        isStreaming.value = false;
        setDefaultMessageInputFieldHeight();
        resetLoadingMessage();
        await sendMessage(trimmed, false);
        return;
      }

      final String title =
          "${conversation.value?.title ?? Strings.newConversation.tr} (${Strings.edit.tr})";
      final PupauConversation? forked =
          await ConversationService.forkConversation(
            assistantId,
            conversation.value!.id,
            title,
            previousMessageId,
            isMarketplace,
          );
      if (forked == null) {
        showErrorSnackbar(Strings.apiErrorGeneric.tr);
        return;
      }
      await loadConversation(forked.id);
      assistantsReplying.value = 0;
      isStreaming.value = false;
      resetLoadingMessage();
      setDefaultMessageInputFieldHeight();
      await sendMessage(trimmed, false);
    } finally {
      isForking.value = false;
      update();
    }
  }

  void setForkConversationTitle(String title) {
    forkConversationTitle.value = title;
    update();
  }

  // CUSTOM ACTIONS

  void openCustomActionsModal() {
    if (assistant.value?.customActions.isNotEmpty ?? false) {
      showCustomActionsModal(assistant.value!.customActions);
    }
  }

  // TOOL USE EXPANSION MANAGEMENT

  void toggleToolUseExpanded(String messageId) async {
    userToggledToolUseMessages.add(messageId);
    userToggledToolUseMessages.refresh();
    if (expandedToolUseMessages.contains(messageId)) {
      expandedToolUseMessages.remove(messageId);
    } else {
      expandedToolUseMessages.add(messageId);
    }
    expandedToolUseMessages.refresh();
    update();
    await Future.delayed(const Duration(milliseconds: 300));
    // Only update if the controller is still active and the message is still in the list
    if (!isClosed && userToggledToolUseMessages.contains(messageId)) {
      userToggledToolUseMessages.remove(messageId);
      userToggledToolUseMessages.refresh();
      update();
    }
  }

  bool isToolUseExpanded(String messageId) =>
      expandedToolUseMessages.contains(messageId);

  //UI TOOL

  void handleUiToolMessage(Map<String, dynamic> data) {
    UiToolMessage uiToolMessage = UiToolMessage.fromJson(data);
    PupauMessage message = PupauMessage(
      id: uiToolMessage.id,
      answer: uiToolMessage.data.message,
      type: null,
      sourceType: SourceType.uiTool,
      assistantType: uiToolMessage.chatBotId != null
          ? AssistantType.assistant
          : AssistantType.marketplace,
      kbReferences: [],
      urls: [],
      uiToolMessage: uiToolMessage,
      assistantId: '',
      createdAt: DateTime.now(),
      status: MessageStatus.received,
    );
    _applyActiveStreamingGroupId(message);
    updateSSEMessages(message);
    if (message.answer.trim() != "") {
      messageNotifier.addData(message.answer, message.id);
    }
  }

  Future<void> sendUiToolApproval(String messageId) async {
    Stream<SSEModel>? sseStream = await UiToolService.approveTool(messageId);
    isStreaming.value = true;
    update();
    if (sseStream != null) {
      _bumpSseIdleTimer();
    }
    messageSendStream = sseStream?.listen(
      (event) {
        _bumpSseIdleTimer();
        setLastEventId(event);
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, false);
        }
      },
      onError: (e) {
        _cancelSseIdleTimer();
        showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.apiErrorSendMessage.tr}",
        );
        manageCancelAndErrorMessage();
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.error,
            payload: {
              "error": "Erorr sending tool approval: ${e.toString()}",
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversationId": conversation.value?.id ?? "",
              "messageId": messageId,
            },
          ),
        );
      },
      onDone: () {
        _cancelSseIdleTimer();
      },
    );
  }

  Future<void> sendToolAnswer(
    String messageId,
    List<AskUserChoice> selectedOptions,
    String? answer,
  ) async {
    Stream<SSEModel>? sseStream = await ToolAskUserService.answerAskUserTool(
      messageId,
      selectedOptions,
      answer,
    );
    isStreaming.value = true;
    update();
    if (sseStream != null) {
      _bumpSseIdleTimer();
    }
    messageSendStream = sseStream?.listen(
      (event) {
        _bumpSseIdleTimer();
        setLastEventId(event);
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, false);
        }
      },
      onError: (e) {
        _cancelSseIdleTimer();
        showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.apiErrorSendMessage.tr}",
        );
        manageCancelAndErrorMessage();
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.error,
            payload: {
              "error": "Error sending tool answer: ${e.toString()}",
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
              "conversationId": conversation.value?.id ?? "",
              "messageId": messageId,
            },
          ),
        );
      },
      onDone: () => _cancelSseIdleTimer(),
    );
  }

  Future<void> sendUiToolAuth(String messageId, String toolId) async {
    showCustomBasicDialog(Strings.googleDriveNotImplemented.tr);
    return;
  }

  // UI TOOL BUBBLE VISIBILITY MANAGEMENT

  void hideUiToolBubble(String messageId) {
    hiddenUiToolMessages.add(messageId);
    hiddenUiToolMessages.refresh();
    update();
  }

  bool isUiToolBubbleHidden(String messageId) =>
      hiddenUiToolMessages.contains(messageId);

  // Input field tools

  bool isAdvanced() =>
      isWebSearchAvailable.value ||
      isAttachmentAvailable.value ||
      (assistant.value?.customActions.isNotEmpty ?? false) ||
      (conversationActiveSkills.isNotEmpty);

  void toggleToolsFab({bool? value}) {
    toolsFabExpanded.value = value ?? !toolsFabExpanded.value;
    update();
  }

  void getMessageInputFieldHeight(BuildContext? context) {
    if (context == null) {
      setDefaultMessageInputFieldHeight();
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.attached) {
      messageInputFieldHeight.value = renderObject.size.height;
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderObject? ro = context.findRenderObject();
      if (ro is RenderBox && ro.attached) {
        messageInputFieldHeight.value = ro.size.height;
      } else {
        setDefaultMessageInputFieldHeight();
      }
    });
  }

  void setDefaultMessageInputFieldHeight() {
    if (isVoiceMode.value) {
      messageInputFieldHeight.value = 210;
      update();
      return;
    }
    final bool isTablet = DeviceService.isTablet;
    final double baseHeight = isTablet ? 74 : 58;
    messageInputFieldHeight.value = baseHeight;
    update();
  }

  // LOADING AND EMPTY MESSAGES

  void clearEmptyMessages() {
    messages.removeWhere((PupauMessage message) => message.isEmpty);
    messages.refresh();
    update();
  }

  void resetLoadingMessage() {
    activeToolLoadings.clear();
    activeToolLoadings.refresh();
    toolPartialStatuses.clear();
    toolPartialStatuses.refresh();
    attachmentToolLoadingLabels.clear();
    attachmentToolLoadingLabels.refresh();
    _loadingToolStartedAt.clear();
    expandedLoadingTools.clear();
    expandedLoadingTools.refresh();
    userToggledLoadingTools.clear();
    userToggledLoadingTools.refresh();
    _stopLoadingToolsTimerIfIdle();
    loadingMessage.value = LoadingMessage(
      message: "",
      loadingType: LoadingType.dots,
    );
    update();
  }

  // LANGUAGE INITIALIZATION

  // Set locale from config
  void initLanguage() {
    if (pupauConfig == null || pupauConfig!.language == PupauLanguage.en) {
      return;
    }

    if (!_translationsInitialized) {
      final localizationService = LocalizationService.getInstance();
      Get.appendTranslations(localizationService.keys);
      _translationsInitialized = true;
    }

    final Locale locale = LocalizationService.getLocaleFromConfig(pupauConfig!);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Get.updateLocale(locale);
    });
  }

  // Audio recording

  Future<void> startRecording() async {
    if (isRecording.value || hasApiError.value) return;
    final String? path = await AudioRecordingService.startRecording();
    if (path == null) return;
    isRecording.value = true;
    recordingDuration.value = Duration.zero;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      recordingDuration.value += const Duration(seconds: 1);
    });
    update();
  }

  Future<void> stopAndSendRecording() async {
    if (!isRecording.value) return;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    isRecording.value = false;
    final File? file = await AudioRecordingService.stopRecording();
    recordingDuration.value = Duration.zero;
    update();
    if (file != null) await sendAudioMessage(file);
  }

  Future<void> cancelRecording() async {
    if (!isRecording.value) return;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    _voiceSilenceTimer?.cancel();
    _voiceSilenceTimer = null;
    _voiceSilenceStart = null;
    voiceSilenceProgress.value = 0.0;
    isRecording.value = false;
    recordingDuration.value = Duration.zero;
    await AudioRecordingService.cancelRecording();
    update();
  }

  /// Immediately submit the current voice recording (bypasses VAD silence wait).
  Future<void> submitVoiceNow() => _autoSendVoiceRecording();

  /// Restart listening from idle (e.g. after the user taps PTT in idle phase).
  Future<void> startListeningNow() => _startVoiceListening();

  void _onVoiceModeStreamingChanged(bool streaming) {
    if (!streaming && isVoiceMode.value && !isRecording.value) {
      // Long fallback: only for turns where no audio event ever fired
      // (e.g. a purely text response). Normal audio turns are handled by
      // audioResponseEnd → _resumeVoiceListeningIfNeeded(), which runs
      // much sooner. Do NOT gate on isVoicePlaying here — audio may not
      // have started yet when the text stream ends.
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!isStreaming.value &&
            isVoiceMode.value &&
            !isRecording.value &&
            !isVoicePlaying.value) {
          _startVoiceListening();
        }
      });
    }
  }

  void toggleVoiceMode() {
    isVoiceMode.value ? _exitVoiceMode() : _enterVoiceMode();
    update();
  }

  /// Called by the chat widget when it is removed from the tree (deactivate),
  /// covering all close paths: back nav, sized-mode collapse, floating-mode close.
  void exitVoiceModeIfActive() {
    if (!isVoiceMode.value) return;
    _exitVoiceMode();
  }

  Future<void> _enterVoiceMode() async {
    isVoiceMode.value = true;
    messageInputFieldHeight.value = 210;
    update();
    if (!isStreaming.value) await _startVoiceListening();
  }

  Future<void> _exitVoiceMode() async {
    isVoiceMode.value = false;
    _stopVoiceAmplitudePolling();
    _voiceSilenceTimer?.cancel();
    _voiceSilenceTimer = null;
    if (isRecording.value) await cancelRecording();
    voiceAmplitude.value = 0.0;
    isVoiceDetected.value = false;
    _voicePlaybackService.clearAll();
    isVoicePlaying.value = false;
    setDefaultMessageInputFieldHeight();
  }

  /// Stops audio playback mid-sentence and resumes listening so the user can
  /// speak again without waiting for the AI to finish talking.
  void stopAudioPlayback() {
    _voicePlaybackService.clearAll();
    isVoicePlaying.value = false;
    _resumeVoiceListeningIfNeeded();
  }

  /// Resumes mic listening after playback ends or is stopped, but only when
  /// in voice mode and no other activity is in progress.
  void _resumeVoiceListeningIfNeeded() {
    if (!isVoiceMode.value || isRecording.value || isStreaming.value) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (isVoiceMode.value &&
          !isRecording.value &&
          !isStreaming.value &&
          !isVoicePlaying.value) {
        _startVoiceListening();
      }
    });
  }

  Future<void> _startVoiceListening() async {
    if (isRecording.value ||
        hasApiError.value ||
        isStreaming.value ||
        isVoicePlaying.value) {
      return;
    }
    if (!isVoiceMode.value) return;
    final String? path = await AudioRecordingService.startRecording();
    if (path == null) return;
    isRecording.value = true;
    VoiceSoundCueService.playStartListening();
    _voiceSessionHadSpeech = false;
    recordingDuration.value = Duration.zero;
    _startVoiceAmplitudePolling();
  }

  void _startVoiceAmplitudePolling() {
    _voiceAmplitudeTimer?.cancel();
    _voiceAmplitudeTimer = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) async => _pollVoiceAmplitude(),
    );
  }

  void _stopVoiceAmplitudePolling() {
    _voiceAmplitudeTimer?.cancel();
    _voiceAmplitudeTimer = null;
  }

  Future<void> _pollVoiceAmplitude() async {
    if (!isRecording.value || !isVoiceMode.value) {
      _stopVoiceAmplitudePolling();
      return;
    }
    final double amp = await AudioRecordingService.getAmplitudeNormalized();
    voiceAmplitude.value = amp;
    if (amp >= _voiceAmplitudeThreshold) {
      isVoiceDetected.value = true;
      _voiceSessionHadSpeech = true;
      _voiceSilenceTimer?.cancel();
      _voiceSilenceTimer = null;
      _voiceSilenceStart = null;
      voiceSilenceProgress.value = 0.0;
    } else {
      isVoiceDetected.value = false;
      if (_voiceSessionHadSpeech && _voiceSilenceTimer == null) {
        _voiceSilenceStart = DateTime.now();
        _voiceSilenceTimer = Timer(_voiceSilenceDelay, () async {
          _voiceSilenceStart = null;
          _voiceSilenceTimer = null;
          voiceSilenceProgress.value = 0.0;
          await _autoSendVoiceRecording();
        });
      }
      if (_voiceSilenceTimer != null && _voiceSilenceStart != null) {
        final int elapsed = DateTime.now()
            .difference(_voiceSilenceStart!)
            .inMilliseconds;
        voiceSilenceProgress.value =
            (elapsed / _voiceSilenceDelay.inMilliseconds).clamp(0.0, 1.0);
      }
    }
  }

  Future<void> _autoSendVoiceRecording() async {
    if (!isRecording.value || !isVoiceMode.value) return;
    _stopVoiceAmplitudePolling();
    voiceAmplitude.value = 0.0;
    isVoiceDetected.value = false;
    _recordingTimer?.cancel();
    _recordingTimer = null;
    isRecording.value = false;
    final File? file = await AudioRecordingService.stopRecording();
    recordingDuration.value = Duration.zero;
    _voiceSessionHadSpeech = false;
    update();
    if (file != null) {
      VoiceSoundCueService.playAudioSent();
      await sendAudioMessage(file, isVoiceMode: true);
    }
  }

  void _handleVoiceAudioEvent(VoiceSseEventType type, Map<String, dynamic> data) {
    // Audio data is nested under the "data" key in each SSE event.
    final dynamic payload = data['data'];
    final Map<String, dynamic> eventData = payload is Map<String, dynamic>
        ? payload
        : const {};
    final String streamId = (eventData['streamId'] as String?) ?? '';

    // Malformed event — no valid stream to operate on.
    if (streamId.isEmpty) return;

    switch (type) {
      case VoiceSseEventType.audioResponseStart:
        _voicePlaybackService.start(streamId);
        // Mark playing immediately so the mic guard activates before audio begins.
        isVoicePlaying.value = true;
      case VoiceSseEventType.audioChunk:
        final String? audioB64 = eventData['audio'] as String?;
        final int audioSeq = (eventData['audioSeq'] as num?)?.toInt() ?? 0;
        if (audioB64 != null && audioB64.isNotEmpty) {
          try {
            _voicePlaybackService.appendChunk(
              streamId,
              audioSeq,
              base64Decode(audioB64),
            );
          } catch (_) {
            // Malformed base64 chunk — skip silently; stream continues.
          }
        }
      case VoiceSseEventType.audioResponseEnd:
        // All chunks received — wait for the streaming play queue to drain.
        _voicePlaybackService
            .end(streamId)
            .then((_) {
              if (!_voicePlaybackService.isDisposed) {
                isVoicePlaying.value = false;
                _resumeVoiceListeningIfNeeded();
              }
            })
            .catchError((Object e) {
              isVoicePlaying.value = false;
              _resumeVoiceListeningIfNeeded();
            });
      case VoiceSseEventType.audioClear:
        // Barge-in or server-side stop.
        _voicePlaybackService.clear(streamId);
        isVoicePlaying.value = false;
        _resumeVoiceListeningIfNeeded();
      case VoiceSseEventType.audioAlignment:
      case VoiceSseEventType.audioUnavailable:
      // Word-timing / unavailable — no playback action needed.
      default:
    }
  }

  Future<void> sendAudioMessage(
    File audioFile, {
    bool isVoiceMode = false,
  }) async {
    keyboardFocusNode.unfocus();
    resetLoadingMessage();
    currentWebSearchType.value = null;
    setExternalSearchButton(false);
    messageNotifier = MessageNotifier();
    messageNotifier.setAssistantId(assistant.value?.id ?? "");
    incomingMessages = [];
    kbReferencesBackup = [];
    isStreaming.value = true;
    chatExtraBottomPaddingActive.value = true;
    latestQueryAssistantClusterHeight.value = 0.0;
    assistantsReplying.value = 1;
    update();
    setDefaultMessageInputFieldHeight();
    final PupauMessage senderMessage = PupauMessage(
      id: 'local_${DateTime.now().microsecondsSinceEpoch}',
      attachments: const [],
      answer: "",
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      isAudioInput: true,
      assistantId: assistantId,
      assistantType: assistant.value?.type ?? AssistantType.assistant,
    );
    _activeStreamingGroupId = _generateStreamingGroupId();
    senderMessage.groupId = _activeStreamingGroupId ?? "";
    addMessage(senderMessage, bypassCheck: true);
    scrollToUserMessage(senderMessage.id);
    addTaggedAssistants();
    if (conversation.value == null) await createNewConversation();
    if (conversation.value == null) return;
    bool isFirstSSEData = true;
    listHeight =
        chatScrollController.positions.lastOrNull?.maxScrollExtent ?? 0;
    messageNotifier.setConversationId(conversation.value?.id ?? "");
    Stream<SSEModel>? sseStream = await SSEService.createSSEStreamAudio(
      assistantId,
      conversation.value?.id ?? "",
      conversation.value?.token ?? "",
      audioFile,
      isWebSearch: isWebSearchActive.value,
      isVoiceMode: isVoiceMode,
      chatController: this,
    );
    if (sseStream != null) {
      _bumpSseIdleTimer();
    }
    if (sseStream == null) {
      showErrorSnackbar(
        "${Strings.apiErrorGeneric.tr} ${Strings.apiErrorSendMessage.tr}",
      );
      _lastFailedAudioFilePath = audioFile.path;
      manageCancelAndErrorMessage();
      assistantsReplying.value = 0;
      return;
    }
    messageSendStream = sseStream.listen(
      (event) {
        _bumpSseIdleTimer();
        setLastEventId(event);
        if (event.data == null || event.data!.trim().isEmpty) return;
        try {
          final Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, false);
          // Stream accepted; we can clear the retry path.
          _lastFailedAudioFilePath = null;
          if (isFirstSSEData) {
            isFirstSSEData = false;
          }
        } catch (_) {}
      },
      onError: (e) {
        _cancelSseIdleTimer();
        showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.apiErrorSendMessage.tr}",
        );
        _lastFailedAudioFilePath = audioFile.path;
        manageCancelAndErrorMessage();
        assistantsReplying.value = 0;
      },
      onDone: () => _cancelSseIdleTimer(),
    );
  }

  void setLastEventId(SSEModel event) {
    final String eventId = (event.id ?? '').trim();
    if (eventId.isNotEmpty && conversation.value != null) {
      PupauSharedPreferences.setLastEventId(conversation.value!.id, eventId);
    }
  }

  bool canRetryAudioMessage(PupauMessage message) {
    if (!message.isAudioInput || !message.isCancelled) return false;
    if (isStreaming.value) return false;
    final String path = (_lastFailedAudioFilePath ?? '').trim();
    if (path.isEmpty) return false;
    return File(path).existsSync();
  }

  Future<void> retryLastFailedAudioMessage() async {
    final String path = (_lastFailedAudioFilePath ?? '').trim();
    if (path.isEmpty) return;
    final File file = File(path);
    if (!file.existsSync()) return;
    await sendAudioMessage(file);
  }
}
