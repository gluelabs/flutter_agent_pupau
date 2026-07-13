import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/voice_session_model.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:http/http.dart' as http;

class VoiceSessionService {
  /// Creates a live voice session. Returns the session data or null on failure.
  static Future<VoiceSession?> createSession({
    required String assistantId,
    required String conversationId,
    required String conversationToken,
    required PupauConfig config,
    bool isMarketplace = false,
  }) async {
    final Map<String, String>? authHeaders = config.authHeaders;
    if (authHeaders == null) return null;
    try {
      final http.Client client = http.Client();
      try {
        final http.Request req = http.Request(
          'POST',
          Uri.parse(
            ApiUrls.voiceSessionsUrl(
              assistantId,
              conversationId,
              isMarketplace: isMarketplace,
            ),
          ),
        );
        req.headers.addAll({
          ...authHeaders,
          'Conversation-Token': conversationToken,
          'Content-Type': 'application/json',
        });
        // Request PCM16 input @ 16kHz; default output
        req.body = jsonEncode({
          'input': {'encoding': 'pcm16', 'sampleRate': 16000},
        });
        final http.StreamedResponse res = await client
            .send(req)
            .timeout(const Duration(seconds: 10));
        final String body = await res.stream.bytesToString();
        if (res.statusCode != 201) return null;
        return VoiceSession.fromMap(
          jsonDecode(body) as Map<String, dynamic>,
        );
      } finally {
        client.close();
      }
    } catch (_) {
      return null;
    }
  }

  /// Opens the SSE events stream for a voice session.
  static Stream<SSEModel>? openEventsStream({
    required String assistantId,
    required String conversationId,
    required VoiceSession session,
    required PupauConfig config,
    bool isMarketplace = false,
  }) {
    final Map<String, String>? authHeaders = config.authHeaders;
    if (authHeaders == null) return null;
    try {
      final String url = ApiUrls.voiceSessionEventsUrl(
        assistantId,
        conversationId,
        session.voiceSessionId,
        session.voiceSessionToken,
        isMarketplace: isMarketplace,
      );
      return SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: url,
        header: {
          ...authHeaders,
          'Accept': 'text/event-stream',
        },
      );
    } catch (_) {
      return null;
    }
  }

  /// Sends a raw PCM16 audio chunk. [seq] must be strictly increasing (0-based).
  static Future<bool> sendAudioChunk({
    required String assistantId,
    required String conversationId,
    required VoiceSession session,
    required PupauConfig config,
    required Uint8List bytes,
    required int seq,
    bool isMarketplace = false,
  }) async {
    final Map<String, String>? authHeaders = config.authHeaders;
    if (authHeaders == null) return false;
    try {
      final http.Client client = http.Client();
      try {
        final http.Request req = http.Request(
          'POST',
          Uri.parse(
            ApiUrls.voiceSessionAudioChunksUrl(
              assistantId,
              conversationId,
              session.voiceSessionId,
              isMarketplace: isMarketplace,
            ),
          ),
        );
        req.headers.addAll({
          'Authorization': 'Bearer ${session.voiceSessionToken}',
          'Content-Type': 'application/octet-stream',
          'X-Voice-Seq': seq.toString(),
        });
        req.bodyBytes = bytes;
        final http.StreamedResponse res = await client
            .send(req)
            .timeout(const Duration(seconds: 5));
        return res.statusCode == 202;
      } finally {
        client.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// Sends a barge-in (client-initiated stop of TTS / agent).
  static Future<bool> sendBargeIn({
    required String assistantId,
    required String conversationId,
    required VoiceSession session,
    required PupauConfig config,
    bool isMarketplace = false,
  }) async {
    final Map<String, String>? authHeaders = config.authHeaders;
    if (authHeaders == null) return false;
    try {
      final http.Client client = http.Client();
      try {
        final http.Request req = http.Request(
          'POST',
          Uri.parse(
            ApiUrls.voiceSessionBargeInUrl(
              assistantId,
              conversationId,
              session.voiceSessionId,
              isMarketplace: isMarketplace,
            ),
          ),
        );
        req.headers.addAll({
          'Authorization': 'Bearer ${session.voiceSessionToken}',
          'Content-Type': 'application/json',
        });
        final http.StreamedResponse res = await client
            .send(req)
            .timeout(const Duration(seconds: 5));
        return res.statusCode == 202;
      } finally {
        client.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// Closes (deletes) the voice session. Idempotent.
  static Future<void> deleteSession({
    required String assistantId,
    required String conversationId,
    required VoiceSession session,
    required PupauConfig config,
    bool isMarketplace = false,
  }) async {
    final Map<String, String>? authHeaders = config.authHeaders;
    if (authHeaders == null) return;
    try {
      final http.Client client = http.Client();
      try {
        final http.Request req = http.Request(
          'DELETE',
          Uri.parse(
            ApiUrls.voiceSessionUrl(
              assistantId,
              conversationId,
              session.voiceSessionId,
              isMarketplace: isMarketplace,
            ),
          ),
        );
        req.headers.addAll({
          'Authorization': 'Bearer ${session.voiceSessionToken}',
        });
        await client.send(req).timeout(const Duration(seconds: 5));
      } finally {
        client.close();
      }
    } catch (_) {}
  }
}
