import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';

class ApiUrls {
  static const String defaultApiUrl = "https://api.pupau.ai";

  /// Override set from [PupauConfig.apiUrl] when chat is opened. If null, [apiUrl] returns [_defaultApiUrl].
  static String? _apiUrlOverride;

  static void setApiUrlOverride(String? url) {
    _apiUrlOverride = url;
  }

  /// Base API URL. Uses [PupauConfig.apiUrl] when set, otherwise defaults to https://api.pupau.ai.
  static String get apiUrl => _apiUrlOverride ?? defaultApiUrl;

  /// Base path for agent-detail endpoints, per agent mode.
  ///
  /// The three modes differ only by this segment - the rest of every path is
  /// identical - which is why a Living Agent is a mode here rather than a
  /// separate client.
  static String assistantsBasePath(PupauAgentMode mode) {
    switch (mode) {
      case PupauAgentMode.livingAgent:
        return 'living-agents';
      case PupauAgentMode.marketplace:
        return 'marketplace';
      case PupauAgentMode.assistant:
        return 'assistants';
    }
  }

  /// Base path for conversation endpoints, per agent mode.
  static String chatBotsBasePath(PupauAgentMode mode) {
    switch (mode) {
      case PupauAgentMode.livingAgent:
        return 'living-agents';
      case PupauAgentMode.marketplace:
        return 'marketplace';
      case PupauAgentMode.assistant:
        return 'chat-bots';
    }
  }

  /// Living Agent turn: SSE is returned in the body of this POST.
  /// Body: `{question, conversationId?}`.
  static String livingAgentChatStreamUrl(String idAgent) =>
      '$apiUrl/living-agents/$idAgent/chat/stream';

  /// Living Agent voice turn: multipart `audio` part plus `conversationId`.
  static String livingAgentChatStreamAudioUrl(String idAgent) =>
      '$apiUrl/living-agents/$idAgent/chat/stream-audio';

  static String get getAssistantsQuickUrl =>
      '$apiUrl/assistants/q?archive=false&showAll=true';

  static String assistantUrl(
    String idAssistant, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) => '$apiUrl/${assistantsBasePath(mode)}/$idAssistant';

  static String conversationsUrl(
    String idAssistant, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) => '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations';

  static String sendQueryUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries?sse=true';

  /// SSE URL for (GET) conversation queries history + catch-up.
  ///
  /// When [lastEventId] is provided, the server can send only events after it.
  static String getQueryUrl(
    String idAssistant,
    String idConversation, {
    String? lastEventId,
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) {
    final String base =
        '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries?sse=true';
    if (lastEventId == null || lastEventId.trim().isEmpty) return base;
    return '$base&lastEventId=$lastEventId';
  }

  /// Stop an active async agent run (if any) for this conversation.
  static String stopConversationRunUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/stop';

  static String conversationUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation';

  static String queriesUrl(
    String idAssistant,
    String idConversation, {
    int page = 0,
    int items = 20,
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries?items=$items&page=$page&showAll=false';

  static String queryUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries/$idQuery';

  /// On-demand cited-chunk snippet (§2.2 of the citations spec).
  static String groundingChunkUrl(
    String embeddingId, {
    required String queryId,
  }) => '$apiUrl/grounding/chunks/$embeddingId?queryId=$queryId';

  /// KB image bytes — `thumb: true` (default) caps the long
  /// side at 512px for inline rendering; `false` is full size, fetched lazily
  /// only when the viewer opens.
  static String ragImageUrl(
    String embeddingId, {
    required String queryId,
    bool thumb = true,
  }) =>
      '$apiUrl/rag/images/$embeddingId?queryId=$queryId${thumb ? '&thumb=1' : ''}';

  static String settingsUrl(PupauAgentMode mode) =>
      '$apiUrl/settings/company${mode == PupauAgentMode.marketplace ? '?isMarketplace=true' : ''}';

  static String settingsUserUrl({PupauAgentMode mode = PupauAgentMode.assistant}) =>
      '$apiUrl/settings/user${mode == PupauAgentMode.marketplace ? '?isMarketplace=true' : ''}';

  static String reactionUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/reactions';

  static String fileDownloadUrl(
    String idAssistant,
    String idConversation,
    String idFile, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/data-source/$idFile';

  static String conversationAttachmentsUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/attachments';

  static String conversationAttachmentUrl(
    String idAssistant,
    String idConversation,
    String idAttachment, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/attachments/$idAttachment';

  static String conversationAttachmentViewUrl(
    String idAssistant,
    String idConversation,
    String idAttachment, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/attachments/$idAttachment/view';

  static String forkConversationUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/fork';

  static String toolApprovalUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      "$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries/$idQuery/tool-approval/?sse=true&systemLang=en-US&customProperties={}";

  static String toolAuthUrl(
    String idAssistant,
    String idConversation,
    String idQuery,
    String idTool,
    String authCode, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      "$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries/$idQuery/tool-auth?sse=true&toolId=$idTool&credentialType=OAUTH2_TOKEN&authCode=$authCode";

  static String toolQuestionUrl(
    String idAssistant,
    String idConversation,
    String idQuery, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      "$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries/$idQuery/user-question-response/?sse=true";

  static String sendAudioQueryUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/queries/audio?sse=true';

  static String get profileUrl => '$apiUrl/auth/profile';

  // ── Voice sessions ────────────────────────────────────────────────────────

  static String voiceSessionsUrl(
    String idAssistant,
    String idConversation, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '$apiUrl/${chatBotsBasePath(mode)}/$idAssistant/conversations/$idConversation/voice-sessions';

  static String voiceSessionUrl(
    String idAssistant,
    String idConversation,
    String vsid, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '${voiceSessionsUrl(idAssistant, idConversation, mode: mode)}/$vsid';

  static String voiceSessionEventsUrl(
    String idAssistant,
    String idConversation,
    String vsid,
    String vst, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '${voiceSessionUrl(idAssistant, idConversation, vsid, mode: mode)}/events?vst=$vst';

  static String voiceSessionAudioChunksUrl(
    String idAssistant,
    String idConversation,
    String vsid, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '${voiceSessionUrl(idAssistant, idConversation, vsid, mode: mode)}/audio-chunks';

  static String voiceSessionBargeInUrl(
    String idAssistant,
    String idConversation,
    String vsid, {
    PupauAgentMode mode = PupauAgentMode.assistant,
  }) =>
      '${voiceSessionUrl(idAssistant, idConversation, vsid, mode: mode)}/barge-in';
}
