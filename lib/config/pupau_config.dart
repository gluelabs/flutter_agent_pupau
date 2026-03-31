import 'package:flutter/material.dart';

/// Configuration class for Pupau Agent package
class PupauConfig {
  /// API key for authentication
  final String? apiKey;

  /// Bearer token for authentication
  final String? bearerToken;

  /// Override the base API URL. If null, defaults to `https://api.pupau.ai`.
  final String? apiUrl;

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

  /// Language used for translations in the plugin. Defaults to [PupauLanguage.en].
  final PupauLanguage language;

  /// API key for Google Maps used for Google Map syntax builder.
  final String? googleMapsApiKey;

  /// Whether to hide the input box. Defaults to false.
  final bool hideInputBox;

  /// List of predefined messages that will be displayed in an empty conversation. The user can tap on a message to start the conversation with it.
  final List<String> conversationStarters;

  /// Widget mode. Defaults to full.
  ///
  /// - `full`: The widget will be displayed in a full screen mode, navigating to the chat page when the user taps on the avatar.
  /// - `sized`: When the user taps the avatar, it will expand in place using the dimensions specified in [sizedConfig]. Can be initially expanded.
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

  /// Configuration for the app bar.
  final AppBarConfig? appBarConfig;

  /// Configuration for the drawer and end drawer.
  final DrawerConfig? drawerConfig;

  /// Whether to reset the chat state on open. Defaults to true.
  final bool resetChatOnOpen;

  /// Optional welcome message passed by the host (e.g. from a list). Used when the
  /// assistant from [getAssistants] has no welcome message, so the chat can show
  /// it immediately without waiting for [getAssistant]. Ignored once the API
  /// returns a welcome message.
  final String? initialWelcomeMessage;

  /// Private constructor - use [createWithApiKey] or [createWithToken] instead
  PupauConfig._internal({
    this.apiKey,
    this.bearerToken,
    this.apiUrl,
    required this.assistantId,
    this.isMarketplace = false,
    this.conversationId,
    this.isAnonymous = false,
    this.language = PupauLanguage.en,
    this.googleMapsApiKey,
    this.hideInputBox = false,
    this.widgetMode = WidgetMode.full,
    this.sizedConfig,
    this.floatingConfig,
    this.showNerdStats = false,
    this.hideAudioRecordingButton = false,
    this.customProperties,
    this.conversationStarters = const [],
    this.appBarConfig,
    this.drawerConfig,
    this.resetChatOnOpen = true,
    this.initialWelcomeMessage,
  });

  /// Factory constructor for creating config with API key
  ///
  /// Get the API key from Pupau web or mobile app, navigate to your agent configuration page and then under the "Integrations - API Key" you will find your agent's API keys.
  /// For marketplace assistants, pass [assistantId] and [isMarketplace: true] so the correct API path is used.
  ///
  /// Example:
  /// ```dart
  /// final config = PupauConfig.createWithApiKey(
  ///   apiKey: 'your-api-key',
  /// );
  /// ```
  factory PupauConfig.createWithApiKey({
    required String apiKey,
    String? apiUrl,
    String? conversationId,
    bool isAnonymous = false,
    PupauLanguage language = PupauLanguage.en,
    String? googleMapsApiKey,
    bool hideInputBox = false,
    WidgetMode widgetMode = WidgetMode.full,
    SizedConfig? sizedConfig,
    FloatingConfig? floatingConfig,
    bool showNerdStats = false,
    bool hideAudioRecordingButton = false,
    dynamic customProperties,
    List<String> conversationStarters = const [],
    AppBarConfig? appBarConfig,
    DrawerConfig? drawerConfig,
    bool resetChatOnOpen = true,
    String? initialWelcomeMessage,
  }) {
    return PupauConfig._internal(
      apiKey: apiKey,
      apiUrl: apiUrl,
      assistantId: assistantIdFromApiKey(apiKey),
      isMarketplace: false,
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
      appBarConfig: appBarConfig,
      drawerConfig: drawerConfig,
      resetChatOnOpen: resetChatOnOpen,
      initialWelcomeMessage: initialWelcomeMessage,
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
    String? apiUrl,
    bool isMarketplace = false,
    String? conversationId,
    bool isAnonymous = false,
    PupauLanguage language = PupauLanguage.en,
    String? googleMapsApiKey,
    bool hideInputBox = false,
    WidgetMode widgetMode = WidgetMode.full,
    SizedConfig? sizedConfig,
    FloatingConfig? floatingConfig,
    bool showNerdStats = false,
    bool hideAudioRecordingButton = false,
    dynamic customProperties,
    List<String> conversationStarters = const [],
    AppBarConfig? appBarConfig,
    DrawerConfig? drawerConfig,
    bool resetChatOnOpen = true,
    String? initialWelcomeMessage,
  }) {
    return PupauConfig._internal(
      bearerToken: bearerToken,
      assistantId: assistantId,
      apiUrl: apiUrl,
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
      appBarConfig: appBarConfig,
      drawerConfig: drawerConfig,
      resetChatOnOpen: resetChatOnOpen,
      initialWelcomeMessage: initialWelcomeMessage,
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

  /// Creates a copy of this config with the given fields replaced with new values.
  /// Note: apiKey, assistantId, and bearerToken cannot be changed as they are locked at creation.
  ///
  /// Example:
  /// ```dart
  /// final newConfig = config.copyWith(
  ///   isAnonymous: true,
  ///   conversationId: null,
  /// );
  /// ```
  PupauConfig copyWith({
    String? apiUrl,
    bool? isMarketplace,
    String? conversationId,
    bool? isAnonymous,
    PupauLanguage? language,
    String? googleMapsApiKey,
    bool? hideInputBox,
    WidgetMode? widgetMode,
    SizedConfig? sizedConfig,
    FloatingConfig? floatingConfig,
    bool? showNerdStats,
    bool? hideAudioRecordingButton,
    dynamic customProperties,
    List<String>? conversationStarters,
    AppBarConfig? appBarConfig,
    DrawerConfig? drawerConfig,
    String? initialWelcomeMessage,
  }) {
    if (apiKey != null) {
      return PupauConfig.createWithApiKey(
        apiKey: apiKey!,
        apiUrl: apiUrl ?? this.apiUrl,
        conversationId: conversationId ?? this.conversationId,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        language: language ?? this.language,
        googleMapsApiKey: googleMapsApiKey ?? this.googleMapsApiKey,
        hideInputBox: hideInputBox ?? this.hideInputBox,
        widgetMode: widgetMode ?? this.widgetMode,
        sizedConfig: sizedConfig ?? this.sizedConfig,
        floatingConfig: floatingConfig ?? this.floatingConfig,
        showNerdStats: showNerdStats ?? this.showNerdStats,
        hideAudioRecordingButton:
            hideAudioRecordingButton ?? this.hideAudioRecordingButton,
        customProperties: customProperties ?? this.customProperties,
        conversationStarters: conversationStarters ?? this.conversationStarters,
        appBarConfig: appBarConfig ?? this.appBarConfig,
        drawerConfig: drawerConfig ?? this.drawerConfig,
        initialWelcomeMessage: initialWelcomeMessage ?? this.initialWelcomeMessage,
      );
    } else if (bearerToken != null) {
      return PupauConfig.createWithToken(
        bearerToken: bearerToken!,
        assistantId: assistantId,
        apiUrl: apiUrl ?? this.apiUrl,
        isMarketplace: isMarketplace ?? this.isMarketplace,
        conversationId: conversationId ?? this.conversationId,
        isAnonymous: isAnonymous ?? this.isAnonymous,
        language: language ?? this.language,
        googleMapsApiKey: googleMapsApiKey ?? this.googleMapsApiKey,
        hideInputBox: hideInputBox ?? this.hideInputBox,
        widgetMode: widgetMode ?? this.widgetMode,
        sizedConfig: sizedConfig ?? this.sizedConfig,
        floatingConfig: floatingConfig ?? this.floatingConfig,
        showNerdStats: showNerdStats ?? this.showNerdStats,
        hideAudioRecordingButton:
            hideAudioRecordingButton ?? this.hideAudioRecordingButton,
        customProperties: customProperties ?? this.customProperties,
        conversationStarters: conversationStarters ?? this.conversationStarters,
        appBarConfig: appBarConfig ?? this.appBarConfig,
        drawerConfig: drawerConfig ?? this.drawerConfig,
        initialWelcomeMessage: initialWelcomeMessage ?? this.initialWelcomeMessage,
      );
    } else {
      throw Exception(
          'Cannot copy config: missing apiKey or bearerToken');
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

  const SizedConfig({
    required this.width,
    required this.height,
    this.initiallyExpanded = false,
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

/// Configuration for the app bar.
class AppBarConfig {
  /// Whether the app bar is shown.
  final bool showAppBar;
  /// List of actions to be displayed in the app bar.
  final List<Widget>? actions;

  /// Style of the close button. Defaults to [CloseStyle.arrow] for Full mode, [CloseStyle.cross] for Sized and Floating modes.
  /// Set to [CloseStyle.none] to hide the close button completely.
  final CloseStyle? closeStyle;

  /// Position of the close button. Defaults to [CloseButtonPosition.left] for Full mode, [CloseButtonPosition.right] for Sized and Floating modes.
  final CloseButtonPosition? closeButtonPosition;

  const AppBarConfig({
    this.showAppBar = true,
    this.actions,
    this.closeStyle,
    this.closeButtonPosition,
  });
}

/// Configuration for the drawer.
class DrawerConfig {
  /// The drawer to be displayed.
  final Widget? drawer;
  /// The end drawer to be displayed.
  final Widget? endDrawer;
  /// Called when the drawer is opened or closed.
  final Function(bool isOpen)? onDrawerChanged;
  /// Called when the end drawer is opened or closed.
  final Function(bool isOpen)? onEndDrawerChanged;
  // Key for Scaffold, allowing to control the drawer from the key
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DrawerConfig({
    this.drawer,
    this.endDrawer,
    this.onDrawerChanged,
    this.onEndDrawerChanged,
    this.scaffoldKey,
  });
}

enum WidgetMode { full, sized, floating }

enum CloseStyle { arrow, cross, none }

enum CloseButtonPosition { left, right }

/// Supported languages for the plugin.
enum PupauLanguage {
  /// English (default)
  en,
  /// German
  de,
  /// Spanish
  es,
  /// French
  fr,
  /// Hindi
  hi,
  /// Italian
  it,
  /// Korean
  ko,
  /// Dutch
  nl,
  /// Polish
  pl,
  /// Portuguese
  pt,
  /// Albanian
  sq,
  /// Swedish
  sv,
  /// Turkish
  tr,
  /// Chinese
  zh;
}