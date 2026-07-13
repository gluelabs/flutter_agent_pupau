import 'package:flutter_agent_pupau/services/json_parse_service.dart';

enum VoiceSessionAgentState { listening, thinking, speaking }

enum VoiceSseEventType {
  voiceSessionState,
  sttPartial,
  utteranceFinal,
  turnStarted,
  answerDelta,
  audioResponseStart,
  audioChunk,
  audioResponseEnd,
  audioClear,
  audioAlignment,
  audioUnavailable,
  steeringAccepted,
  messageCompleteMirror,
  voiceSessionRecovered,
  voiceSessionClosed,
  voiceSessionError,
  unknown;

  bool get isAudioEvent => switch (this) {
        audioResponseStart ||
        audioChunk ||
        audioResponseEnd ||
        audioClear ||
        audioAlignment ||
        audioUnavailable =>
          true,
        _ => false,
      };
}

VoiceSseEventType voiceSseEventTypeFromString(String? s) => switch (s) {
      'VOICE_SESSION_STATE'    => VoiceSseEventType.voiceSessionState,
      'STT_PARTIAL'            => VoiceSseEventType.sttPartial,
      'UTTERANCE_FINAL'        => VoiceSseEventType.utteranceFinal,
      'TURN_STARTED'           => VoiceSseEventType.turnStarted,
      'ANSWER_DELTA'           => VoiceSseEventType.answerDelta,
      'AUDIO_RESPONSE_START'   => VoiceSseEventType.audioResponseStart,
      'AUDIO_CHUNK'            => VoiceSseEventType.audioChunk,
      'AUDIO_RESPONSE_END'     => VoiceSseEventType.audioResponseEnd,
      'AUDIO_CLEAR'            => VoiceSseEventType.audioClear,
      'AUDIO_ALIGNMENT'        => VoiceSseEventType.audioAlignment,
      'AUDIO_UNAVAILABLE'      => VoiceSseEventType.audioUnavailable,
      'STEERING_ACCEPTED'      => VoiceSseEventType.steeringAccepted,
      'MESSAGE_COMPLETE_MIRROR' => VoiceSseEventType.messageCompleteMirror,
      'VOICE_SESSION_RECOVERED' => VoiceSseEventType.voiceSessionRecovered,
      'VOICE_SESSION_CLOSED'   => VoiceSseEventType.voiceSessionClosed,
      'VOICE_SESSION_ERROR'    => VoiceSseEventType.voiceSessionError,
      _                        => VoiceSseEventType.unknown,
    };

VoiceSessionAgentState voiceAgentStateFromString(String? s) {
  switch (s) {
    case 'THINKING':
      return VoiceSessionAgentState.thinking;
    case 'SPEAKING':
      return VoiceSessionAgentState.speaking;
    default:
      return VoiceSessionAgentState.listening;
  }
}

class VoiceAudioInputConfig {
  final String encoding; // pcm16 | opus
  final int sampleRate;
  const VoiceAudioInputConfig({
    required this.encoding,
    required this.sampleRate,
  });
  factory VoiceAudioInputConfig.fromMap(Map<String, dynamic> json) =>
      VoiceAudioInputConfig(
        encoding: getString(json['encoding']).isNotEmpty ? getString(json['encoding']) : 'pcm16',
        sampleRate: json['sampleRate'] as int? ?? 16000,
      );
}

class VoiceAudioOutputConfig {
  final String format; // pcm16 | mp3 | opus | wav
  final int sampleRate;
  const VoiceAudioOutputConfig({
    required this.format,
    required this.sampleRate,
  });
  factory VoiceAudioOutputConfig.fromMap(Map<String, dynamic> json) =>
      VoiceAudioOutputConfig(
        format: getString(json['format']).isNotEmpty ? getString(json['format']) : 'pcm16',
        sampleRate: json['sampleRate'] as int? ?? 24000,
      );
}

class VoiceSessionLimits {
  final int idleTimeoutMs;
  final int maxSessionSec;
  const VoiceSessionLimits({
    required this.idleTimeoutMs,
    required this.maxSessionSec,
  });
  factory VoiceSessionLimits.fromMap(Map<String, dynamic> json) =>
      VoiceSessionLimits(
        idleTimeoutMs: json['idleTimeoutMs'] as int? ?? 60000,
        maxSessionSec: json['maxSessionSec'] as int? ?? 3600,
      );
}

class VoiceSession {
  final String voiceSessionId;
  final String voiceSessionToken;
  final VoiceAudioInputConfig inputConfig;
  final VoiceAudioOutputConfig outputConfig;
  final VoiceSessionLimits limits;

  const VoiceSession({
    required this.voiceSessionId,
    required this.voiceSessionToken,
    required this.inputConfig,
    required this.outputConfig,
    required this.limits,
  });

  factory VoiceSession.fromMap(Map<String, dynamic> json) {
    final audio = json['audio'] as Map<String, dynamic>? ?? {};
    return VoiceSession(
      voiceSessionId: getString(json['voiceSessionId']),
      voiceSessionToken: getString(json['voiceSessionToken']),
      inputConfig: VoiceAudioInputConfig.fromMap(
        audio['input'] as Map<String, dynamic>? ?? {},
      ),
      outputConfig: VoiceAudioOutputConfig.fromMap(
        audio['output'] as Map<String, dynamic>? ?? {},
      ),
      limits: VoiceSessionLimits.fromMap(
        json['limits'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
