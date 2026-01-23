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
/// - PupauChatUtils: Utilities for programmatically controlling the chat
/// - PupauEventService: Event streams for listening to chat events
library;

// Configuration - includes PupauConfig, WidgetMode, SizedConfig, FloatingConfig, FloatingAnchor
export 'config/pupau_config.dart';

// Avatar widget - the main UI component users interact with
export 'chat_page/pupau_agent_avatar.dart';

// Chat utilities - for programmatic control
export 'utils/pupau_chat_utils.dart';

// Event service - for listening to chat events
export 'services/pupau_event_service.dart';

