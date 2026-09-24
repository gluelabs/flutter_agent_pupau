/// Public API for flutter_agent_pupau package
/// 
/// This file exports only the public API that plugin users should access.
/// Import this file to use the Pupau Agent plugin:
/// ```dart
/// import 'package:flutter_agent_pupau/pupau_agent.dart';
/// ```
library;

// Configuration - includes PupauConfig, WidgetMode, SizedConfig, FloatingConfig, FloatingAnchor
export 'config/pupau_config.dart';

// Agent modes: assistant / marketplace / living agent
export 'config/pupau_agent_mode.dart';

/// Context attachable to a single Living Agent turn.
export 'models/pupau_living_agent_context.dart';

// Avatar widget - the main UI component users interact with
export 'chat_page/pupau_agent_avatar.dart';

// Chat utilities - for programmatic control
export 'utils/pupau_chat_utils.dart';

// Event service - for listening to chat events
export 'services/pupau_event_service.dart';

// Chat page widget - for hosts that mount the chat as their own route or
// embed it, rather than pushing it with [PupauChatUtils.openChat].
export 'chat_page/pupau_agent_chat.dart' show PupauAgentChat;
