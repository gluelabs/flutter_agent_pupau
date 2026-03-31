class ApiUrls {
  static const String defaultApiUrl = "https://api.pupau.ai";

  /// Override set from [PupauConfig.apiUrl] when chat is opened. If null, [apiUrl] returns [_defaultApiUrl].
  static String? _apiUrlOverride;

  static void setApiUrlOverride(String? url) {
    _apiUrlOverride = url;
  }

  /// Base API URL. Uses [PupauConfig.apiUrl] when set, otherwise defaults to https://api.pupau.ai.
  static String get apiUrl => _apiUrlOverride ?? defaultApiUrl;

  /// Helper method to get the base path for assistants endpoints
  static String assistantsBasePath(bool isMarketplace) =>
      isMarketplace ? 'marketplace' : 'assistants';

  /// Helper method to get the base path for chat-bots endpoints
  static String chatBotsBasePath(bool isMarketplace) =>
      isMarketplace ? 'marketplace' : 'chat-bots';

  static String get getAssistantsQuickUrl =>
      '$apiUrl/assistants/q?archive=false&showAll=true';

  static String assistantUrl(
    String idAssistant, {
    bool isMarketplace = false,
  }) => '$apiUrl/${assistantsBasePath(isMarketplace)}/$idAssistant';

  static String conversationsUrl(
    String idAssistant, {
    bool isMarketplace = false,
  }) => '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations';

  static String sendQueryUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries?sse=true';

  /// SSE URL for (GET) conversation queries history + catch-up.
  ///
  /// When [lastEventId] is provided, the server can send only events after it.
  static String getQueryUrl(
    String idAssistant,
    String idConversation, {
    String? lastEventId,
    bool isMarketplace = false,
  }) {
    final String base =
        '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries?sse=true';
    if (lastEventId == null || lastEventId.trim().isEmpty) return base;
    return '$base&lastEventId=$lastEventId';
  }

  /// Stop an active async agent run (if any) for this conversation.
  static String stopConversationRunUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/stop';

  static String conversationUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation';

  static String queriesUrl(
    String idAssistant,
    String idConversation, {
    int page = 0,
    int items = 20,
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries?items=$items&page=$page&showAll=false';

  static String queryUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries/$idQuery';

  static String settingsUrl(bool isMarketplace) =>
      '$apiUrl/settings/company${isMarketplace ? '?isMarketplace=true' : ''}';

  static String reactionUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/reactions';

  static String fileDownloadUrl(
    String idAssistant,
    String idConversation,
    String idFile, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/data-source/$idFile';

  static String conversationAttachmentsUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/attachments';

  static String conversationAttachmentUrl(
    String idAssistant,
    String idConversation,
    String idAttachment, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/attachments/$idAttachment';

  static String conversationAttachmentViewUrl(
    String idAssistant,
    String idConversation,
    String idAttachment, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/attachments/$idAttachment/view';

  static String forkConversationUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/fork';

  static String toolApprovalUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    bool isMarketplace = false,
  }) =>
      "$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries/$idQuery/tool-approval/?sse=true&systemLang=en-US&customProperties={}";

  static String toolAuthUrl(
    String idAssistant,
    String idConversation,
    String idQuery,
    String idTool,
    String authCode, {
    bool isMarketplace = false,
  }) =>
      "$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries/$idQuery/tool-auth?sse=true&toolId=$idTool&credentialType=OAUTH2_TOKEN&authCode=$authCode";

  static String toolQuestionUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    bool isMarketplace = false,
  }) =>
      "$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries/$idQuery/user-question-response/?sse=true";

  static String sendAudioQueryUrl(
    String idAssistant,
    String idConversation, {
    bool isMarketplace = false,
  }) =>
      '$apiUrl/${chatBotsBasePath(isMarketplace)}/$idAssistant/conversations/$idConversation/queries/audio?sse=true';
}
