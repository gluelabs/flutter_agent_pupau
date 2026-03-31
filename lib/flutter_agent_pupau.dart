/// Main library file for flutter_agent_pupau package
/// 
/// Import this file to get access to all public APIs:
/// ```dart
/// import 'package:flutter_agent_pupau/flutter_agent_pupau.dart';
/// ```
/// 
/// This provides access to:
/// - PupauConfig: Configuration for the plugin (createWithApiKey, createWithToken)
/// - PupauAgentAvatar: Avatar widget for displaying the chat
/// - PupauAgentPreloader: Headless preloader to warm plugin state (use in lists so opening chat is instant)
/// - PupauChatUtils: Utilities for programmatically controlling the chat (including preloadAssistantsList)
/// - PupauEventService: Event streams for listening to chat events
library;

// Configuration - includes PupauConfig, WidgetMode, SizedConfig, FloatingConfig, FloatingAnchor
export 'config/pupau_config.dart';

// Avatar widget - the main UI component users interact with
export 'chat_page/pupau_agent_avatar.dart';

// Headless preloader - warms plugin controllers/assistant list so chat opens instantly.
// In your host app, import from this package (not a local copy) so the plugin's state is warmed.
export 'chat_page/components/chat_elements/pupau_agent_preloader.dart';

// Chat utilities - for programmatic control
export 'utils/pupau_chat_utils.dart';

// Event service - for listening to chat events
export 'services/pupau_event_service.dart';

// Modal utilities - exposes getSafeModalContext for external use
export 'chat_page/utils/modal_utils.dart';
