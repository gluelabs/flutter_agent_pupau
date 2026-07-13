import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Streaming-first VoicePlaybackService.
///
/// Instead of buffering the entire TTS response before playing, playback
/// starts after a short initial buffer (~100 ms) and continues in batches
/// as chunks arrive, eliminating the multi-second startup delay.
///
/// Protocol:
///   start(streamId)                   ← AUDIO_RESPONSE_START
///   appendChunk(streamId, seq, bytes)  ← AUDIO_CHUNK (base64-decoded)
///   end(streamId)                      ← AUDIO_RESPONSE_END
///   clear(streamId)                    ← AUDIO_CLEAR  (barge-in / stop)
///
/// Audio format: PCM16 LE, mono, 24 kHz.
class VoicePlaybackService {
  final AudioPlayer _player = AudioPlayer();

  /// streamId → { audioSeq → pcmBytes }
  final Map<String, Map<int, Uint8List>> _streams = {};

  bool _disposed = false;
  bool get isDisposed => _disposed;

  String? _activeStreamId;
  int _nextPlaySeq = 0;  // next audioSeq we expect to play
  bool _playing = false; // _playPcm is currently running
  bool _ended = false;   // AUDIO_RESPONSE_END received for active stream

  /// Resolved by _completeEnd() once all audio has played (or on clear).
  Completer<void>? _endCompleter;

  /// Resolved by _resolvePlayCompleter() so _playPcm() can unblock on clear.
  Completer<void>? _playCompleter;
  StreamSubscription? _completeSub;

  /// Fires ~100 ms after the first chunk to kick off early playback.
  Timer? _startTimer;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  void dispose() {
    _disposed = true;
    _cancelStartTimer();
    _streams.clear();
    _resolvePlayCompleter();
    _completeEnd();
    _player.dispose();
  }

  // ── Public API ───────────────────────────────────────────────────────────

  void start(String streamId) {
    if (_disposed) return;
    _streams[streamId] = {};
    _activeStreamId = streamId;
    _nextPlaySeq = 0;
    _playing = false;
    _ended = false;
    _cancelStartTimer();
  }

  void appendChunk(String streamId, int audioSeq, Uint8List bytes) {
    if (_disposed) return;
    _streams.putIfAbsent(streamId, () => {});
    _streams[streamId]![audioSeq] = bytes;

    // Schedule an early flush as soon as we have data for the active stream
    // and playback hasn't started yet.
    if (!_playing && streamId == _activeStreamId) {
      _startTimer ??= Timer(const Duration(milliseconds: 100), () {
        _startTimer = null;
        _flush();
      });
    }
  }

  /// Called on AUDIO_RESPONSE_END. Cancels the start timer, flushes any
  /// remaining buffered chunks, then waits until the play queue drains.
  Future<void> end(String streamId) async {
    if (_disposed) return;
    if (streamId != _activeStreamId) return;

    _cancelStartTimer();
    _ended = true;

    // Always set up the completer before _flush() so _completeEnd() can't
    // fire in a later microtask before we start awaiting.
    _endCompleter = Completer<void>();

    if (!_playing) {
      // Nothing is playing yet — flush remaining chunks now.
      _flush(); // intentionally not awaited; _flush resolves _endCompleter
    }
    // If _playing == true, the running _flush() loop will call _completeEnd()
    // after the queue drains.

    await _endCompleter!.future;
  }

  void clear(String streamId) {
    if (_disposed) return;
    _cancelStartTimer();
    _streams.remove(streamId);
    _playing = false;
    _ended = false;
    _player.stop();
    _resolvePlayCompleter();
    _completeEnd();
  }

  void clearAll() {
    if (_disposed) return;
    _cancelStartTimer();
    _streams.clear();
    _playing = false;
    _ended = false;
    _player.stop();
    _resolvePlayCompleter();
    _completeEnd();
  }

  // ── Internal playback loop ───────────────────────────────────────────────

  void _cancelStartTimer() {
    _startTimer?.cancel();
    _startTimer = null;
  }

  void _completeEnd() {
    if (_endCompleter != null && !_endCompleter!.isCompleted) {
      _endCompleter!.complete();
    }
    _endCompleter = null;
  }

  /// Collect all available sequential chunks (from _nextPlaySeq), play them
  /// as one WAV, then recurse to catch anything that arrived during playback.
  Future<void> _flush() async {
    if (_disposed || _activeStreamId == null) return;

    final chunks = _streams[_activeStreamId!];
    final List<Uint8List> batch = [];

    if (chunks != null) {
      while (chunks.containsKey(_nextPlaySeq)) {
        batch.add(chunks.remove(_nextPlaySeq)!);
        _nextPlaySeq++;
      }
    }

    if (batch.isEmpty) {
      _playing = false;
      if (_ended) _completeEnd();
      return;
    }

    // Assemble batch into one contiguous PCM buffer.
    final int totalLength = batch.fold(0, (sum, b) => sum + b.length);
    final Uint8List pcm = Uint8List(totalLength);
    int offset = 0;
    for (final b in batch) {
      pcm.setRange(offset, offset + b.length, b);
      offset += b.length;
    }

    _playing = true;
    await _playPcm(pcm);

    if (_disposed) {
      _playing = false;
      _completeEnd();
      return;
    }

    // After this batch finishes, check for chunks that arrived during playback.
    await _flush();
  }

  void _resolvePlayCompleter() {
    _completeSub?.cancel();
    _completeSub = null;
    if (_playCompleter != null && !_playCompleter!.isCompleted) {
      _playCompleter!.complete();
    }
    _playCompleter = null;
  }

  Future<void> _playPcm(Uint8List pcm, {int sampleRate = 24000}) async {
    final Uint8List wav = _buildWav(pcm, sampleRate: sampleRate);
    String? path;
    try {
      final Directory dir = await getTemporaryDirectory();
      path = '${dir.path}/voice_resp_${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).writeAsBytes(wav);

      if (_disposed) return;

      // Cancel any leftover listener/completer from a previous call.
      _resolvePlayCompleter();

      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playAndRecord,
            options: {
              AVAudioSessionOptions.defaultToSpeaker,
              AVAudioSessionOptions.allowBluetooth,
            },
          ),
          android: const AudioContextAndroid(
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      if (_disposed) return;

      _playCompleter = Completer<void>();
      _completeSub = _player.onPlayerComplete.listen((_) {
        _resolvePlayCompleter();
      });

      await _player.play(DeviceFileSource(path));

      await _playCompleter!.future.timeout(
        const Duration(minutes: 3),
        onTimeout: _resolvePlayCompleter,
      );
    } catch (_) {
      // Ensure any waiting _flush() is not left hanging if playback setup fails.
      _resolvePlayCompleter();
    } finally {
      // Clean up the temp WAV file regardless of playback outcome.
      if (path != null) {
        try { File(path).deleteSync(); } catch (_) {}
      }
    }
  }

  // ── WAV header builder ───────────────────────────────────────────────────

  static Uint8List _buildWav(
    Uint8List pcm, {
    int sampleRate = 24000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final int dataLength = pcm.length;
    final ByteData h = ByteData(44);

    h.setUint8(0, 0x52); h.setUint8(1, 0x49);
    h.setUint8(2, 0x46); h.setUint8(3, 0x46); // 'RIFF'
    h.setUint32(4, 36 + dataLength, Endian.little);
    h.setUint8(8, 0x57); h.setUint8(9, 0x41);
    h.setUint8(10, 0x56); h.setUint8(11, 0x45); // 'WAVE'

    h.setUint8(12, 0x66); h.setUint8(13, 0x6D);
    h.setUint8(14, 0x74); h.setUint8(15, 0x20); // 'fmt '
    h.setUint32(16, 16, Endian.little);
    h.setUint16(20, 1, Endian.little); // PCM
    h.setUint16(22, channels, Endian.little);
    h.setUint32(24, sampleRate, Endian.little);
    h.setUint32(28, sampleRate * channels * bitDepth ~/ 8, Endian.little);
    h.setUint16(32, channels * bitDepth ~/ 8, Endian.little);
    h.setUint16(34, bitDepth, Endian.little);

    h.setUint8(36, 0x64); h.setUint8(37, 0x61);
    h.setUint8(38, 0x74); h.setUint8(39, 0x61); // 'data'
    h.setUint32(40, dataLength, Endian.little);

    final Uint8List wav = Uint8List(44 + dataLength);
    wav.setRange(0, 44, h.buffer.asUint8List());
    wav.setRange(44, 44 + dataLength, pcm);
    return wav;
  }
}
