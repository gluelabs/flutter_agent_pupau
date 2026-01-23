import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class AssistantApiKeyConfig {
  final bool showCloseButtons;
  final bool showNewConversationButton;
  final bool forceFullMode;
  final String privacyPolicyURL;
  final String termsOfServiceURL;
  final int maxMessagePerConversation; // 0 means unlimited
  final String tooManyMessageErrorText;
  final int webComponentOpenerSize;
  final String position;
  final int marginBottom;
  final List<String> chatEngagementPrompts;
  final ApiKeyEngagementPromptMode chatEngagementPromptMode;
  final int chatEngagementPromptRotateTime;
  final bool engagementSound;
  final bool hidePupauBranding;
  final String headerColor;

  const AssistantApiKeyConfig({
    this.showCloseButtons = true,
    this.showNewConversationButton = true,
    this.forceFullMode = false,
    this.privacyPolicyURL = '',
    this.termsOfServiceURL = '',
    this.maxMessagePerConversation = 20,
    this.tooManyMessageErrorText = '',
    this.webComponentOpenerSize = 70,
    this.position = 'right',
    this.marginBottom = 10,
    required this.chatEngagementPrompts,
    this.chatEngagementPromptMode = ApiKeyEngagementPromptMode.rotate,
    this.chatEngagementPromptRotateTime = 5,
    this.engagementSound = true,
    this.hidePupauBranding = false,
    this.headerColor = '#15559d',
  });

  factory AssistantApiKeyConfig.fromJson(Map<String, dynamic> json) {
    return AssistantApiKeyConfig(
      showCloseButtons: json['showCloseButtons'] ?? true,
      showNewConversationButton: json['showNewConversationButton'] ?? true,
      forceFullMode: json['forceFullMode'] ?? false,
      privacyPolicyURL: json['privacyPolicyURL'] ?? '',
      termsOfServiceURL: json['termsOfServiceURL'] ?? '',
      maxMessagePerConversation: getInt(
        json['maxMessagePerConversation'] ?? 20,
      ),
      tooManyMessageErrorText: json['tooManyMessageErrorText'] ?? '',
      webComponentOpenerSize: getInt(json['webComponentOpenerSize'] ?? 70),
      position: json['position'] ?? 'right',
      marginBottom: getInt(json['marginBottom'] ?? 10),
      chatEngagementPrompts: json['chatEngagementPrompts'] is Iterable
          ? (json['chatEngagementPrompts'] as List)
                .where((item) => item != null)
                .map((item) => item?.toString() ?? "")
                .toList()
          : [],
      chatEngagementPromptMode: getApiKeyEngagementPromptModeEnum(
        json['chatEngagementPromptMode'],
      ),
      chatEngagementPromptRotateTime: getInt(
        json['chatEngagementPromptRotateTime'] ?? 5,
      ),
      engagementSound: json['engagementSound'] ?? true,
      hidePupauBranding: json['hidePupauBranding'] ?? false,
      headerColor: json['headerColor'] ?? '#15559d',
    );
  }

  static ApiKeyEngagementPromptMode getApiKeyEngagementPromptModeEnum(
    String? promptMode,
  ) {
    if (promptMode == null) return ApiKeyEngagementPromptMode.rotate;
    switch (promptMode.toLowerCase()) {
      case "rotate":
        return ApiKeyEngagementPromptMode.rotate;
      case "random":
        return ApiKeyEngagementPromptMode.random;
      default:
        return ApiKeyEngagementPromptMode.rotate;
    }
  }
}

enum ApiKeyEngagementPromptMode { rotate, random }
