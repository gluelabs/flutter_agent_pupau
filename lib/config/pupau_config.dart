/// Configuration class for Pupau Agent package
class PupauConfig {
  /// API key for authentication
  final String? apiKey;

  /// Bearer token for authentication
  final String? bearerToken;

  /// The id of the assistant to use.
  final String assistantId;

  /// Whether the assistant is a marketplace assistant. Defaults to false.
  ///
  /// Settable only on bearer token creation.
  final bool isMarketplace;

  /// If set when entering the chat page, the conversation with this id will be loaded. If not set, a new conversation will be created on first message sent.
  final String? conversationId;

  /// Whether the chat will be anonymous, ignores conversation id if true. Defaults to false.
  final bool isAnonymous;

  /// Language code used for translations in the plugin. If not set, defaults to `'en'`.
  ///
  /// Supported values: `'de'`, `'en'`, `'es'`, `'fr'`, `'hi'`, `'it'`, `'ko'`, `'nl'`, `'pl'`, `'pt'`, `'sq'`, `'sv'`, `'tr'`, `'zh'`.
  final String? language;

  /// API key for Google Maps used for Google Map syntax builder.
  final String? googleMapsApiKey;

  /// Whether to hide the input box. Defaults to false.
  final bool hideInputBox;

  /// List of predefined messages that will be displayed in an empty conversation. The user can tap on a message to start the conversation with it.
  final List<String> conversationStarters;

  /// Widget mode. Defaults to full.
  ///
  /// - `full`: The widget will be displayed in a full screen mode, navigating to the chat page when the user taps on the avatar.
  /// - `sized`: When the user taps the avatar, it will expand in place using the dimensions specified in [sizedConfig]. Can be initially expanded and show or hide the close button.
  /// - `floating`: When the user taps the avatar, it will show as a floating overlay dialog using the dimensions and anchor specified in [floatingConfig].
  final WidgetMode widgetMode;

  /// Configuration for sized widget mode. Only used when [widgetMode] is [WidgetMode.sized].
  final SizedConfig? sizedConfig;

  /// Configuration for floating widget mode. Only used when [widgetMode] is [WidgetMode.floating].
  final FloatingConfig? floatingConfig;

  /// Whether to show stats regarding tokens, credits and context size. Defaults to false.
  final bool showNerdStats;

  /// Whether the audio recording button is hidden. See README for details on permissions setup.
  final bool hideAudioRecordingButton;

  /// Custom properties, useful to pass custom data to the agent.
  final dynamic customProperties;

  /// Private constructor - use [createWithApiKey] or [createWithToken] instead
  PupauConfig._internal({
    this.apiKey,
    this.bearerToken,
    required this.assistantId,
    this.isMarketplace = false,
    this.conversationId,
    this.isAnonymous = false,
    this.language,
    this.googleMapsApiKey,
    this.hideInputBox = false,
    this.widgetMode = WidgetMode.full,
    this.sizedConfig,
    this.floatingConfig,
    this.showNerdStats = false,
    this.hideAudioRecordingButton = false,
    this.customProperties,
    this.conversationStarters = const [],
  });

  /// Factory constructor for creating config with API key
  ///
  /// Get the API key from Pupau web or mobile app, navigate to your agent configuration page and then under the "Integrations - API Key" you will find your agent's API keys.
  ///
  /// Example:
  /// ```dart
  /// final config = PupauConfig.createWithApiKey(
  ///   apiKey: 'your-api-key',
  /// );
  /// ```
  factory PupauConfig.createWithApiKey({
    required String apiKey,
    String? conversationId,
    bool isAnonymous = false,
    String? language,
    String? googleMapsApiKey,
    bool hideInputBox = false,
    WidgetMode widgetMode = WidgetMode.full,
    SizedConfig? sizedConfig,
    FloatingConfig? floatingConfig,
    bool showNerdStats = false,
    bool hideAudioRecordingButton = false,
    dynamic customProperties,
    List<String> conversationStarters = const [],
  }) {
    return PupauConfig._internal(
      apiKey: apiKey,
      assistantId: assistantIdFromApiKey(apiKey),
      conversationId: conversationId,
      isAnonymous: isAnonymous,
      language: language,
      googleMapsApiKey: googleMapsApiKey,
      hideInputBox: hideInputBox,
      widgetMode: widgetMode,
      sizedConfig: sizedConfig,
      floatingConfig: floatingConfig,
      showNerdStats: showNerdStats,
      hideAudioRecordingButton: hideAudioRecordingButton,
      customProperties: customProperties,
      conversationStarters: conversationStarters,
    );
  }

  /// Factory constructor for creating config with bearer token
  ///
  ///
  /// Example:
  /// ```dart
  /// final config = PupauConfig.createWithToken(
  ///   bearerToken: 'your-bearer-token',
  ///   assistantId: 'your-assistant-id',
  /// );
  /// ```
  factory PupauConfig.createWithToken({
    required String bearerToken,
    required String assistantId,
    bool isMarketplace = false,
    String? conversationId,
    bool isAnonymous = false,
    String? language,
    String? googleMapsApiKey,
    bool hideInputBox = false,
    WidgetMode widgetMode = WidgetMode.full,
    SizedConfig? sizedConfig,
    FloatingConfig? floatingConfig,
    bool showNerdStats = false,
    bool hideAudioRecordingButton = false,
    dynamic customProperties,
    List<String> conversationStarters = const [],
  }) {
    return PupauConfig._internal(
      bearerToken: bearerToken,
      assistantId: assistantId,
      isMarketplace: isMarketplace,
      conversationId: conversationId,
      isAnonymous: isAnonymous,
      language: language,
      googleMapsApiKey: googleMapsApiKey,
      hideInputBox: hideInputBox,
      widgetMode: widgetMode,
      sizedConfig: sizedConfig,
      floatingConfig: floatingConfig,
      showNerdStats: showNerdStats,
      hideAudioRecordingButton: hideAudioRecordingButton,
      customProperties: customProperties,
      conversationStarters: conversationStarters,
    );
  }

  /// Returns the appropriate header key and value for authentication as a Map.
  /// For static access, use PupauConfig.getAuthParams() instead.
  Map<String, String>? get authHeaders {
    try {
      if (apiKey != null) {
        return {"Api-Key": apiKey!};
      } else if (bearerToken != null) {
        return {"Authorization": "Bearer $bearerToken"};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static String assistantIdFromApiKey(String apiKey) {
    int dashIndex = apiKey.indexOf("-");
    if (dashIndex == -1) return "";
    return apiKey.substring(0, dashIndex);
  }
}

/// Configuration for sized widget mode.
/// When the chat is expanded, it will use the specified width and height.
class SizedConfig {
  /// Width of the chat widget.
  final double width;
  /// Height of the chat widget.
  final double height;
  /// Whether the chat is initially expanded.
  final bool initiallyExpanded;
  /// Whether the close button is shown.
  final bool hasCloseButton;

  const SizedConfig({
    required this.width,
    required this.height,
    this.initiallyExpanded = false,
    this.hasCloseButton = true
  });
}

/// Anchor position for floating overlay relative to the avatar widget.
enum FloatingAnchor { bottomRight, bottomLeft, topRight, topLeft }

/// Configuration for floating widget mode.
/// When the chat is shown as an overlay, it will use the specified width, height, and anchor position.
class FloatingConfig {
  /// Width of the chat overlay.
  final double width;
  /// Height of the chat overlay.
  final double height;
  /// Anchor position relative to the avatar widget. Defaults to [FloatingAnchor.bottomRight].
  final FloatingAnchor anchor;

  const FloatingConfig({
    required this.width,
    required this.height,
    this.anchor = FloatingAnchor.bottomRight,
  });
}

enum WidgetMode { full, sized, floating }
