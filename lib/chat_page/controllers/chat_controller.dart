import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_image_full.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/custom_actions_modal.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/message_service.dart';
import 'package:flutter_agent_pupau/services/sse_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/my_mention_tag_text_editing_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/fork_conversation_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_notifier.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_basic_dialog.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/loading_message_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';
import 'package:flutter_agent_pupau/models/ui_tool_message_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_ask_user_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/services/tts_service.dart';
import 'package:flutter_agent_pupau/services/ui_tool_service.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/localization_service.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/assistants_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class ChatController extends GetxController {
  ChatController({PupauConfig? config}) : pupauConfig = config;
  PupauConfig? pupauConfig;
  String get assistantId => pupauConfig?.assistantId ?? "";
  bool get isMarketplace => pupauConfig?.isMarketplace ?? false;
  bool get isAnonymous => pupauConfig?.isAnonymous ?? false;
  bool get hideInputBox => pupauConfig?.hideInputBox ?? false;
  WidgetMode get widgetMode => pupauConfig?.widgetMode ?? WidgetMode.full;
  RxList<String> conversationStarters = <String>[].obs;

  // Store the BuildContext from the main widget for modal usage
  BuildContext? _modalContext;
  void setModalContext(BuildContext context) {
    _modalContext = context;
  }

  // Get safe context for modals - prefer stored context, fallback to Get.context
  BuildContext? get safeContext => _modalContext ?? Get.context;

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

  // Guard to prevent concurrent initializations
  bool _isInitializing = false;

  MyMentionTagTextEditingController inputMessageController =
      MyMentionTagTextEditingController();
  RxString inputMessage = "".obs;
  ScrollController chatScrollController = ScrollController();
  Rxn<Assistant> assistant = Rxn<Assistant>();
  RxList<Assistant> taggedAssistants = <Assistant>[].obs;
  Rxn<Conversation> conversation = Rxn<Conversation>();
  RxList<PupauMessage> messages = <PupauMessage>[].obs;
  RxBool externalSearchVisible = false.obs;
  RxBool hasApiError = false.obs;
  final FocusNode keyboardFocusNode = FocusNode();
  RxBool isLoadingConversation = false.obs;
  MessageNotifier messageNotifier = MessageNotifier();
  StreamSubscription? messageSendStream;
  RxBool isStreaming = false.obs;
  RxInt assistantsReplying = 0
      .obs; //Set to 1 when sending a message without tags, set to n when sending a message with n tags. Tied to isStreaming logic
  TtsService ttsService = TtsService();
  List<PupauMessage> incomingMessages = [];
  RxBool isLoadingTitle = false.obs;
  RxDouble messageInputFieldHeight = 0.0.obs;
  RxBool isMessageInputFieldFocused = false.obs;
  double listHeight = 0.0;
  Rx<LoadingMessage> loadingMessage = LoadingMessage(
    message: "",
    loadingType: LoadingType.dots,
  ).obs; //Used as simple loading message, Layer message for pipeline, query message for websearch
  bool isConversationHistoryLoaded = false;

  RxBool toolsFabExpanded = false.obs;

  //Conversation pagination variables
  bool isConversationLastPage = false;
  bool isLoadingConversationPage = false;
  int conversationPage = 0;
  int conversationItemsLoaded = 0;

  //Conversation scroll variables
  bool autoScrollEnabled = true;
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

  // Fork
  RxString forkMessageId = "".obs;
  RxString forkConversationTitle = "".obs;
  TextEditingController forkConversationTitleController =
      TextEditingController();

  // Tool Use Management
  RxSet<String> expandedToolUseMessages = <String>{}.obs;
  RxList<String> userToggledToolUseMessages = <String>[].obs;

  // UI Tool Bubble Visibility Management
  RxSet<String> hiddenUiToolMessages = <String>{}.obs;

  // Image Full Screen
  Rxn<ChatImage> selectedImage = Rxn<ChatImage>();
  Map<String, Uint8List> cachedToolUseImages = {};

  // KB References
  List<KbReference> kbReferencesBackup =
      []; //Used in case first message is MessageType.kb and following messages are not SourceType.llm

  // Translations
  static bool _translationsInitialized = false;

  // Event tracking variables
  DateTime? _currentMessageStartTime;
  bool _hasReceivedFirstToken = false;
  bool _isFirstMessage = true;

  // Conversation Starter
  bool get showConversationStarters =>
      conversationStarters.isNotEmpty &&
      conversation.value == null &&
      pupauConfig?.conversationId == null &&
      messages.isEmpty &&
      filteredAssistants.isEmpty;

  @override
  onInit() {
    setDefautMessageInputFieldHeight();
    openChatWithConfig(pupauConfig);
    ttsService.initTextToSpeach(config: pupauConfig);
    PupauSharedPreferences.init();
    super.onInit();
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
    messageSendStream?.cancel();
    chatScrollController.dispose();
    // Set boot status to OFF when component is closed
    _updateBootStatus(BootState.off);
    super.onClose();
  }

  //CONTROLLER - CONVERSATIONS INIT

  /// Resets all chat state when the chat is opened
  /// This ensures a fresh state each time the chat is opened
  void resetChatState({bool isManualReset = false}) {
    _hasCompletedFirstInit = false;
    if (isManualReset) {
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.resetConversation,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
          },
        ),
      );
    }
    // Reset conversation and messages
    conversation.value = null;
    messages.clear();
    incomingMessages.clear();
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

    // Reset tagged assistants and mentions
    clearTaggedAssistants();
    mentionValue.value = "";
    filteredAssistants.clear();

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
    autoScrollEnabled = true;
    isAtTop.value = true;
    isAtBottom.value = true;
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
    // Prevent concurrent initializations
    if (_isInitializing) return;

    // Check if assistant changed
    bool assistantChanged =
        pupauConfig?.assistantId != newConfig?.assistantId ||
        pupauConfig?.isMarketplace != newConfig?.isMarketplace;

    if (newConfig != null) pupauConfig = newConfig;
    if (assistantChanged) resetChatState();
    _updateBootStatus(BootState.pending);

    // Initialize chat with current config (always re-initialize when chat is opened)
    _isInitializing = true;
    try {
      await initChatController();
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> initChatController() async {
    try {
      initScrollControllers();
      initLanguage();
      hasApiError.value = false;

      // Initialize AssistantsController and load assistants after ChatController is ready
      if (Get.isRegistered<AssistantsController>()) {
        final assistantsController = Get.find<AssistantsController>();
        // Only load if assistants list is empty (not already loaded)
        if (assistantsController.assistants.isEmpty) {
          await assistantsController.getAssistants();
        }
        assistants = assistantsController.assistants;
      }

      await getAssistant();
      messageNotifier.setAssistantId(assistant.value?.id ?? "");
      if (assistant.value != null) {
        // Component successfully booted - config received and first remote call succeeded
        _updateBootStatus(BootState.ok);
        if (DeviceService.isTablet) setDefautMessageInputFieldHeight();
        if (hasApiError.value) {
          _updateBootStatus(BootState.error);
          return;
        }
        if (!isAnonymous &&
            pupauConfig?.conversationId != null &&
            pupauConfig?.conversationId?.trim() != "") {
          await loadConversation(pupauConfig?.conversationId ?? "");
        }

        _hasCompletedFirstInit = true;
        _onFirstInitCompleteCallback?.call();
        _onFirstInitCompleteCallback = null;
      } else {
        _updateBootStatus(BootState.error);
      }
    } catch (e) {
      _updateBootStatus(BootState.error);
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error initializing chat controller: ${e.toString()}",
          },
        ),
      );
    }
  }

  void resetConversation() {
    conversation.value = null;
    isStreaming.value = false;
    messages.clear();
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
    Get.find<AttachmentsController>().clearAttachments();
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
              "conversationId": conversation.value!.id,
            },
          ),
        );
        isConversationHistoryLoaded = false;
        return;
      }
    } catch (e) {
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error creating new conversation: ${e.toString()}",
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
          },
        ),
      );
    }
  }

  void setMessageInputFieldFocused(bool isFocused) {
    isMessageInputFieldFocused.value = isFocused;
    update();
  }

  Future<void> getAssistant() async {
    try {
      assistant.value = await AssistantService.getAssistant(
        pupauConfig?.assistantId ?? "",
        isMarketplace,
      );
      if (assistant.value == null) {
        hasApiError.value = true;
        _updateBootStatus(BootState.error);
        update();
        return;
      }
      setAssistantSettings();
      // Boot status will be set to OK in initChatController after successful initialization
    } catch (e) {
      _updateBootStatus(BootState.error);
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": "Error getting assistant: ${e.toString()}",
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
          },
        ),
      );
    }
  }

  // MESSAGES

  Future<void> sendMessage(String query, bool isExternalSearch) async {
    keyboardFocusNode.unfocus();
    resetLoadingMessage();
    currentWebSearchType.value = null;
    scrollToBottomChat();
    setExternalSearchButton(false);
    messageNotifier = MessageNotifier();
    messageNotifier.setAssistantId(assistant.value?.id ?? "");
    incomingMessages = [];
    inputMessageController.clear();
    inputMessage.value = "";
    kbReferencesBackup = [];
    isStreaming.value = true;

    // Track message start time for metrics
    _currentMessageStartTime = DateTime.now();
    _hasReceivedFirstToken = false;
    List<Attachment> attachments =
        Get.find<AttachmentsController>().getAttachments;
    final PupauMessage senderMessage = PupauMessage(
      id: "",
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
    for (Attachment attachment in attachments) {
      attachment.isShown = true;
    }
    addMessage(senderMessage, bypassCheck: true);
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
    Stream<SSEModel>? sseStream = await SSEService.createSSEStrean(
      assistantId,
      conversation.value?.id ?? "",
      conversation.value?.token ?? "",
      query,
      isExternalSearch: isExternalSearch,
      isWebSearch: isWebSearchActive.value,
      chatController: this,
    );
    messageSendStream = sseStream?.listen(
      (event) {
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, isExternalSearch);
          if (isFirstSSEData) {
            isFirstSSEData = false;
            autoScrollEnabled = true;
          }
        }
      },
      onError: (e) {
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
    );
  }

  void manageSSEData(Map<String, dynamic> data, bool isExternalSearch) {
    PupauMessage newMessage = PupauMessage.fromSseStream(data);
    resetLoadingMessage();
    messages
            .firstWhereOrNull((message) => message.status == MessageStatus.sent)
            ?.id =
        newMessage.id;
    messages.refresh();
    update();

    // Track first token received (not heartbeat or empty messages)
    if (!_hasReceivedFirstToken && _currentMessageStartTime != null) {
      _hasReceivedFirstToken = true;
      final timeToFirstToken = DateTime.now()
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
      final totalSeconds = DateTime.now()
          .difference(_currentMessageStartTime!)
          .inSeconds;
      if (totalSeconds > 0 && newMessage.contextInfo!.outputTokens > 0) {
        final tokensPerSecond =
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
      handleToolUseMessage(data);
      return;
    }
    if (newMessage.sourceType == SourceType.uiTool) {
      handleUiToolMessage(data);
      return;
    }
    if (newMessage.type == MessageType.kb) {
      handleKbMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.conversationTitleGenerated) {
      updateConversationTitle(title: newMessage.title);
      return;
    }
    if (newMessage.type == MessageType.layerMessage) {
      handleLayerMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.toolUseStart) {
      handleToolUseStartMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.webSearchQuery) {
      handleWebSearchQueryMessage(newMessage);
      return;
    }
    if (newMessage.type == MessageType.layerResponse ||
        newMessage.type == MessageType.webSearch ||
        newMessage.type == MessageType.retry) {
      return;
    }
    bool messageIsEmpty = newMessage.answer == "";
    PupauMessage updatedMessage = updateSSEMessages(newMessage);
    if (!messageIsEmpty) {
      messageNotifier.addData(updatedMessage.answer, updatedMessage.id);
      manageChatAutoScroll();
    }
    MessageService.checkSSEErrors(newMessage);
    if (MessageService.canEnableExternalSearch(newMessage, isExternalSearch)) {
      setExternalSearchButton(true);
    }
    if (newMessage.isLast == true) {
      assistantsReplying.value--;
      manageSendSuccess(isExternalSearch);
    }
  }

  void handleToolUseStartMessage(PupauMessage message) {
    if (message.showTool == false && message.toolMessage != null) {
      loadingMessage.value = LoadingMessage(
        message: message.toolMessage ?? "",
        loadingType: LoadingType.text,
      );
      update();
      return;
    }
    if (message.isBrowserTool == true) {
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
        message.type == MessageType.toolUseStart) {
      loadingMessage.value = LoadingMessage(
        message: message.toolName ?? "",
        loadingType: LoadingType.toolUse,
        toolUseType: message.toolUseType,
      );
      update();
      return;
    }
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
    updateSSEMessages(message);
    if (message.answer.trim() != "") {
      messageNotifier.addData(message.answer, message.id);
      manageChatAutoScroll(bypassHeightCheck: true);
    }
    if (isDocument) {
      conversation.value != null
          ? Get.find<AttachmentsController>().loadAttachments()
          : Get.find<AttachmentsController>().clearAttachments();
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
    } else {
      if (kbReferencesBackup.isNotEmpty) addKbBackupToMessage(message);
      updateSSEMessages(message);
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

  PupauMessage updateSSEMessages(PupauMessage newSseMessage) {
    PupauMessage? sseMessage = incomingMessages.firstWhereOrNull(
      (PupauMessage message) => message.id == newSseMessage.id,
    );
    if (sseMessage == null) {
      incomingMessages.add(newSseMessage);
      addMessage(newSseMessage);
      messages.refresh();
      update();
      return newSseMessage;
    } else {
      sseMessage.mergeWith(newSseMessage);
      messages.refresh();
      update();
      return sseMessage;
    }
  }

  void manageSendSuccess(bool isExternalSearch) {
    isStreaming.value = assistantsReplying.value > 0;

    // Calculate time to complete when streaming finishes
    if (!isStreaming.value && _currentMessageStartTime != null) {
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
      clearEmptyMessages();
      resetLoadingMessage();
      updateConversationTitle();
      manageChatAutoScroll(bypassHeightCheck: true);
    }
    messages.refresh();
    update();
  }

  Future<void> updateConversationTitle({String? title}) async {
    if (title != null) {
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
      return;
    }
    isLoadingTitle.value = conversation.value?.hasTempTitle ?? true;
    update();
    await Future.delayed(const Duration(milliseconds: 1500));
    if (conversation.value != null &&
        conversation.value!.hasTempTitle &&
        assistant.value != null) {
      conversation.value = await ConversationService.getConversation(
        assistantId,
        conversation.value!.id,
        isMarketplace,
      );
      conversation.refresh();
      isLoadingTitle.value = false;
      update();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (conversation.value != null &&
          conversation.value!.hasTempTitle &&
          assistant.value != null) {
        conversation.value = await ConversationService.getConversation(
          assistantId,
          conversation.value!.id,
          isMarketplace,
        );
        conversation.refresh();
        update();
      }
    }
  }

  void manageChatAutoScroll({bool bypassHeightCheck = false}) {
    if (!chatScrollController.hasClients || !autoScrollEnabled) return;

    double newListHeight =
        chatScrollController.positions.lastOrNull?.maxScrollExtent ?? 0;
    if (listHeight != newListHeight || bypassHeightCheck) {
      // Use postFrameCallback when bypassing height check to ensure layout is updated
      if (bypassHeightCheck) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (autoScrollEnabled && chatScrollController.hasClients) {
            scrollToBottomChat();
            // Update listHeight after scrolling
            listHeight =
                chatScrollController.positions.lastOrNull?.maxScrollExtent ?? 0;
          }
        });
      } else {
        scrollToBottomChat();
        listHeight = newListHeight;
      }
    }
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

  void sendCancel() {
    if (messageSendStream != null) {
      messageSendStream!.cancel();
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
    }
  }

  void manageCancelAndErrorMessage() {
    isStreaming.value = false;
    PupauMessage? userMessage = messages.firstWhereOrNull(
      (message) => message.status == MessageStatus.sent,
    );
    userMessage?.isCancelled = true;
    PupauMessage? assistantMessage = messages.firstWhereOrNull(
      (message) =>
          message.status != MessageStatus.sent && message.id == userMessage?.id,
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
    update();
  }

  bool stopIsActive() => isStreaming.value;

  bool sendIsActive() => !isStreaming.value && inputMessage.value.trim() != "";

  bool isLoadingMessageActive() =>
      isStreaming.value &&
          (messages.firstOrNull?.status == MessageStatus.sent ||
              messages.firstOrNull?.answer.trim() == "" ||
              messages.firstOrNull?.toolUseMessage != null ||
              (messages.firstOrNull?.uiToolMessage != null &&
                  hiddenUiToolMessages.contains(
                    messages.firstOrNull?.uiToolMessage?.id,
                  ))) ||
      (isLoadingConversation.value && messages.isEmpty);

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

  Future<void> loadConversation(
    String conversationId, {
    bool isManualLoad = false,
  }) async {
    try {
      if (isManualLoad) {
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.conversationChanged,
            payload: {"conversationId": conversationId},
          ),
        );
      }
      resetConversation();
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
      Get.find<AttachmentsController>().loadAttachments();
      await loadConversationMessages(reset: true);
      if (conversation.value != null && messages.length > 1) {
        _isFirstMessage = false;
      }
      isLoadingConversation.value = false;
      isConversationHistoryLoaded = true;
      update();
      scrollToBottomChat();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.conversationChanged,
          payload: {
            "assistantId": assistantId,
            "assistantType": assistant.value?.type ?? AssistantType.assistant,
            "conversationId": conversation.value!.id,
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
          List<dynamic> items = response.data['items'] ?? [];
          if (items.isNotEmpty) {
            List<PupauMessage> queryList = messagesFromLoadedChat(
              jsonEncode(items),
            );
            for (PupauMessage message in queryList) {
              PupauMessage userMessage = MessageService.getUserLoadedMessage(
                message,
              );
              if (isFirstMessageInGroup(message.groupId)) {
                messages.insert(0, userMessage);
              }
              PupauMessage assistantMessage =
                  MessageService.getAssistantLoadedMessage(message);
              messages.insert(0, assistantMessage);
            }
          }
          int total = response.data['total'] ?? 0;
          conversationItemsLoaded += items.length;
          if (total > 0) {
            isConversationLastPage = conversationItemsLoaded >= total;
          } else {
            isConversationLastPage = items.length < 20;
          }
          conversationPage++;
          messages.refresh();
          update();
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

  // SCROLL MANAGEMENT

  void initScrollControllers() {
    chatScrollController.addListener(() {
      const double topDistanceForStatus = 200.0;
      const double topDistanceForPagination = 500.0;
      double currentPixels =
          chatScrollController.positions.lastOrNull?.pixels ?? 0;
      bool isTop = currentPixels <= topDistanceForStatus;
      bool isBottom =
          (chatScrollController.positions.lastOrNull?.pixels ?? 0) >=
          (chatScrollController.positions.lastOrNull?.maxScrollExtent ?? 0) -
              100;
      bool shouldLoadConversationQueries =
          currentPixels <= topDistanceForPagination;
      isAtTop.value = isTop;
      isAtBottom.value = isBottom;
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

  void scrollToBottomChat({bool withAnimation = false}) {
    if (!chatScrollController.hasClients || conversation.value == null) {
      return;
    }

    void performScroll() async {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!chatScrollController.hasClients) return;

      final position = chatScrollController.positions.lastOrNull;
      if (position == null) return;

      final maxScrollExtent = position.maxScrollExtent;
      final currentScrollPosition = position.pixels;

      // Don't scroll if there's no content to scroll (maxScrollExtent is 0 or negative)
      if (maxScrollExtent <= 0) return;

      // Don't scroll if already very close to bottom (within 20px) to prevent bounce
      final distanceFromBottom = maxScrollExtent - currentScrollPosition;

      final scrollDistance = distanceFromBottom.abs();

      // For large scroll distances (>1500px) or when animation is not requested,
      // use jumpTo for instant, lag-free scrolling
      // For small distances with animation requested, use animateTo for smooth UX
      const largeScrollThreshold = 1500.0;

      if (!withAnimation || scrollDistance > largeScrollThreshold) {
        // Instant jump - much faster for large content
        chatScrollController.jumpTo(maxScrollExtent);
      } else {
        // Smooth animation only for small scrolls when explicitly requested
        // Use easeInOut to prevent bounce - it smoothly accelerates and decelerates
        chatScrollController.animateTo(
          maxScrollExtent,
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

  void stopAutoScroll() => autoScrollEnabled = false;

  //MISC

  void manageMessageContextMenu(int selectedOption, PupauMessage message) {
    switch (selectedOption) {
      case 0: //Like
        if (message.reaction != Reaction.like) {
          reactMessage(message, Reaction.like);
        } else {
          reactMessage(message, Reaction.none);
        }
      case 1: //Dislike
        if (message.reaction != Reaction.dislike) {
          reactMessage(message, Reaction.dislike);
        } else {
          reactMessage(message, Reaction.none);
        }
      case 2: //Copy
        Clipboard.setData(
          ClipboardData(
            text: ConversationService.copyMessageWithoutTags(
              message.isMessageFromAssistant ? message.answer : message.query,
            ),
          ),
        );
        showFeedbackSnackbar(
          Strings.copiedClipboard.tr,
          Symbols.content_copy,
          isInfo: true,
        );
      case 3: //Use
        inputMessageController.text = message.isMessageFromAssistant
            ? message.answer
            : message.query;
        inputMessage.value = message.isMessageFromAssistant
            ? message.answer
            : message.query;
        messages.refresh();
        update();
      case 4: //Read
        ttsService.startReading(message, messages, this);
      case 5: //Fork
        openForkConversationModal(message.id);
      case 6: //Report
        reportMessage(message);
    }
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
          .toList()
          .obs;
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
    UsageSettings? usageSettings = assistant.value?.usageSettings;
    if (usageSettings != null) {
      isAttachmentAvailable.value = usageSettings.canAttach;
      isActionBarAlwaysVisible.value = usageSettings.actionBarAlwaysVisible;
      isWebSearchAvailable.value = usageSettings.canWebSearch;
      isMentionAvailable.value = usageSettings.canTag;
      if ((pupauConfig?.isAnonymous ?? false) &&
          assistant.value?.usageSettings?.canAnonymous == false) {
        PupauEventService.instance.emitPupauEvent(
          PupauEvent(
            type: UpdateConversationType.error,
            payload: {
              "error":
                  "Anonymous conversations are not allowed for this assistant. Please use a different assistant or create a new conversation.",
              "assistantId": assistantId,
              "assistantType": assistant.value?.type ?? AssistantType.assistant,
            },
          ),
        );
        await showCustomBasicDialog(
          Strings.anonymousConversationsNotAllowed.tr,
        );
        manageForceBack();
      }
    }
    if (pupauConfig?.conversationStarters.isNotEmpty ?? false) {
      conversationStarters.value = pupauConfig?.conversationStarters ?? [];
    } else {
      List<String> chatEngagementPrompts =
          assistant.value?.apiKeyConfig?.chatEngagementPrompts ?? [];
      if (chatEngagementPrompts.isNotEmpty) {
        conversationStarters.value = chatEngagementPrompts;
      }
    }
    conversationStarters.refresh();
    showNerdStats.value = pupauConfig?.showNerdStats ?? false;
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
    Conversation? forkConversation = await ConversationService.forkConversation(
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
    updateSSEMessages(message);
    if (message.answer.trim() != "") {
      messageNotifier.addData(message.answer, message.id);
      manageChatAutoScroll();
    }
  }

  Future<void> sendUiToolApproval(String messageId) async {
    Stream<SSEModel>? sseStream = await UiToolService.approveTool(messageId);
    isStreaming.value = true;
    update();
    messageSendStream = sseStream?.listen(
      (event) {
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, false);
        }
      },
      onError: (e) {
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
    messageSendStream = sseStream?.listen(
      (event) {
        if (event.data != null) {
          Map<String, dynamic> data = jsonDecode(event.data!);
          manageSSEData(data, false);
        }
      },
      onError: (e) {
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
      (assistant.value?.customActions.isNotEmpty ?? false);

  void toggleToolsFab({bool? value}) {
    toolsFabExpanded.value = value ?? !toolsFabExpanded.value;
    update();
  }

  void getMessageInputFieldHeight(BuildContext? context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context != null) {
        RenderObject? renderBox = context.findRenderObject();
        if (renderBox != null && renderBox is RenderBox && renderBox.attached) {
          messageInputFieldHeight.value = renderBox.size.height;
          update();
        } else {
          setDefautMessageInputFieldHeight();
        }
      } else {
        setDefautMessageInputFieldHeight();
      }
    });
  }

  void setDefautMessageInputFieldHeight() {
    messageInputFieldHeight.value = DeviceService.isTablet ? 74 : 58;
    update();
  }

  // LOADING AND EMPTY MESSAGES

  void clearEmptyMessages() {
    messages.removeWhere(
      (PupauMessage message) =>
          (message.status == MessageStatus.received &&
          message.answer.trim() == "" &&
          message.images.isEmpty &&
          message.news.isEmpty &&
          message.organicInfo.isEmpty &&
          message.graphInfo == null &&
          message.urls.isEmpty &&
          message.relatedSearches.isEmpty &&
          message.toolUseAgent == null &&
          message.toolUseMessage == null &&
          message.uiToolMessage == null),
    );
    messages.refresh();
    update();
  }

  void resetLoadingMessage() {
    loadingMessage.value = LoadingMessage(
      message: "",
      loadingType: LoadingType.dots,
    );
    update();
  }

  // LANGUAGE INITIALIZATION

  // Set locale from config if language is specified
  void initLanguage() {
    if (pupauConfig?.language == null) return;

    if (!_translationsInitialized) {
      final localizationService = LocalizationService.getInstance();
      Get.appendTranslations(localizationService.keys);
      _translationsInitialized = true;
    }

    final locale = LocalizationService.getLocaleFromConfig(pupauConfig);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (locale != null) Get.updateLocale(locale);
    });
  }
}
