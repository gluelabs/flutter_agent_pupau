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

// Avatar widget - the main UI component users interact with
export 'chat_page/pupau_agent_avatar.dart';

// Chat utilities - for programmatic control
export 'utils/pupau_chat_utils.dart';

// Event service - for listening to chat events
export 'services/pupau_event_service.dart';
