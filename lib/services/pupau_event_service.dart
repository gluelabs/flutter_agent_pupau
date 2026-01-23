import 'dart:async';

/// Service for listening to Pupau Agent events
///
/// This service provides streams for various events that occur in the plugin.
/// External apps can listen to these events without needing GetX.
///
/// Example:
/// ```dart
/// PupauEventService.pupauStream.listen((event) {
///   print('Event: ${event.type} - ${event.payload}');
/// });
/// ```
class PupauEventService {
  PupauEventService._(); // Private constructor for singleton

  // Singleton instance
  static final PupauEventService _instance = PupauEventService._();
  static PupauEventService get instance => _instance;

  // Stream controllers for conversation load events
  final StreamController<PupauEvent> _pupauStreamController =
      StreamController<PupauEvent>.broadcast();

  /// Stream of pupau events
  static Stream<PupauEvent> get pupauStream =>
      _instance._pupauStreamController.stream;

  /// Emit a pupau event
  /// Internal use only - called by ChatController
  void emitPupauEvent(PupauEvent event) {
    if (!_pupauStreamController.isClosed) {
      _pupauStreamController.add(event);
    }
  }

  /// Dispose the service (called internally)
  void dispose() {
    _pupauStreamController.close();
  }
}

class PupauEvent {
  final UpdateConversationType type;
  final dynamic payload;
  PupauEvent({required this.type, required this.payload});
}

enum UpdateConversationType {
  componentBootStatus,
  newConversation,
  resetConversation,
  conversationChanged,
  firstMessageComplete,
  messageSent,
  messageReceived,
  stopMessage,
  deleteConversation,
  windowClose,
  historyToggle,
  noCredit,
  error,
  authError,
  tokensPerSecond,
  timeToComplete,
  timeToFirstToken,
  conversationTitleGenerated,
}

enum BootState {
  off,
  pending,
  ok,
  error;

  String get value {
    switch (this) {
      case BootState.off:
        return 'OFF';
      case BootState.pending:
        return 'PENDING';
      case BootState.ok:
        return 'OK';
      case BootState.error:
        return 'ERROR';
    }
  }
}
