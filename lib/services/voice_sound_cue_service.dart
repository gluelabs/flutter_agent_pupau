import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Plays short synthesised beep tones as UI feedback during voice mode.
/// Tones are generated in-memory as PCM16 sine waves — no asset files needed.
class VoiceSoundCueService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _disposed = false;

  static void dispose() {
    _disposed = true;
    _player.dispose();
  }

  /// Played when the microphone starts listening.
  /// Low-to-high two-tone chirp: 520 Hz → 780 Hz.
  static Future<void> playStartListening() async {
    if (_disposed) return;
    final Uint8List tone1 = _generateTone(frequency: 520, durationMs: 80, amplitude: 0.22);
    final Uint8List tone2 = _generateTone(frequency: 780, durationMs: 80, amplitude: 0.22);
    final Uint8List pcm = Uint8List(tone1.length + tone2.length)
      ..setRange(0, tone1.length, tone1)
      ..setRange(tone1.length, tone1.length + tone2.length, tone2);
    await _playPcm(pcm);
  }

  /// Played when the voice recording is sent successfully.
  /// High-to-low two-tone chirp: 780 Hz → 520 Hz.
  static Future<void> playAudioSent() async {
    if (_disposed) return;
    final Uint8List tone1 = _generateTone(frequency: 780, durationMs: 80, amplitude: 0.22);
    final Uint8List tone2 = _generateTone(frequency: 520, durationMs: 80, amplitude: 0.22);
    final Uint8List pcm = Uint8List(tone1.length + tone2.length)
      ..setRange(0, tone1.length, tone1)
      ..setRange(tone1.length, tone1.length + tone2.length, tone2);
    await _playPcm(pcm);
  }

  static Future<void> _playPcm(Uint8List pcm, {int sampleRate = 24000}) async {
    final Uint8List wav = _buildWav(pcm, sampleRate: sampleRate);
    String? path;
    try {
      final Directory dir = await getTemporaryDirectory();
      path = '${dir.path}/voice_cue_${DateTime.now().millisecondsSinceEpoch}.wav';
      await File(path).writeAsBytes(wav);

      if (_disposed) return;

      // Use playAndRecord so the cue is compatible with an active recording
      // session — no category switching needed, mic capture continues uninterrupted.
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
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );

      if (_disposed) return;
      await _player.play(DeviceFileSource(path));
    } catch (_) {
      // Best-effort: if the cue fails, voice mode continues normally.
    } finally {
      if (path != null) {
        try { File(path).deleteSync(); } catch (_) {}
      }
    }
  }

  static Uint8List _generateTone({
    required double frequency,
    required int durationMs,
    int sampleRate = 24000,
    double amplitude = 0.25,
  }) {
    final int sampleCount = sampleRate * durationMs ~/ 1000;
    final Uint8List pcm = Uint8List(sampleCount * 2);
    final ByteData bd = pcm.buffer.asByteData();
    for (int i = 0; i < sampleCount; i++) {
      final double t = i / sampleRate;
      final double env = _envelope(i, sampleCount);
      final double sample = sin(2 * pi * frequency * t) * amplitude * env;
      final int value = (sample * 32767).round().clamp(-32768, 32767);
      bd.setInt16(i * 2, value, Endian.little);
    }
    return pcm;
  }

  /// Fade in for first 10 %, sustain, fade out for last 30 %.
  static double _envelope(int i, int total) {
    final double fadeInEnd = total * 0.10;
    final double fadeOutStart = total * 0.70;
    if (i < fadeInEnd) return i / fadeInEnd;
    if (i > fadeOutStart) return 1.0 - ((i - fadeOutStart) / (total - fadeOutStart));
    return 1.0;
  }

  static Uint8List _buildWav(
    Uint8List pcm, {
    int sampleRate = 24000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final int dataLength = pcm.length;
    final ByteData h = ByteData(44);
    h.setUint8(0, 0x52); h.setUint8(1, 0x49);
    h.setUint8(2, 0x46); h.setUint8(3, 0x46);
    h.setUint32(4, 36 + dataLength, Endian.little);
    h.setUint8(8, 0x57); h.setUint8(9, 0x41);
    h.setUint8(10, 0x56); h.setUint8(11, 0x45);
    h.setUint8(12, 0x66); h.setUint8(13, 0x6D);
    h.setUint8(14, 0x74); h.setUint8(15, 0x20);
    h.setUint32(16, 16, Endian.little);
    h.setUint16(20, 1, Endian.little);
    h.setUint16(22, channels, Endian.little);
    h.setUint32(24, sampleRate, Endian.little);
    h.setUint32(28, sampleRate * channels * bitDepth ~/ 8, Endian.little);
    h.setUint16(32, channels * bitDepth ~/ 8, Endian.little);
    h.setUint16(34, bitDepth, Endian.little);
    h.setUint8(36, 0x64); h.setUint8(37, 0x61);
    h.setUint8(38, 0x74); h.setUint8(39, 0x61);
    h.setUint32(40, dataLength, Endian.little);
    final Uint8List wav = Uint8List(44 + dataLength);
    wav.setRange(0, 44, h.buffer.asUint8List());
    wav.setRange(44, 44 + dataLength, pcm);
    return wav;
  }
}
