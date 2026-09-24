import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_agent_pupau/chat_page/components/shared/setting_denied_dialog.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../utils/translations/strings_enum.dart';

/// Handles audio recording for voice messages. Uses [record] package (wav format).
class AudioRecordingService {
  static final AudioRecorder recorder = AudioRecorder();
  static String? currentPath;

  /// Request microphone permission. Returns true if granted.
  /// Shows settings dialog if permission is permanently denied.
  static Future<bool> requestPermission() async {
    if (await Permission.microphone.isGranted) return true;

    PermissionStatus status = await Permission.microphone.request();

    if (status.isGranted) {
      // Freshly granted (as opposed to the already-granted early return
      // above) - on Android, starting MediaRecorder/AudioRecord
      // immediately after the runtime permission dialog resolves can
      // silently fail (no exception, recording just never starts):
      // permission_handler's Future resolves as soon as
      // onRequestPermissionsResult fires, but the OS's own
      // AppOpsManager/audio HAL grant propagation isn't necessarily done
      // by then. Debug builds' extra overhead (JIT, slower isolate
      // scheduling) normally masks this gap; release/AOT builds run fast
      // enough to hit it - this reproduced as "asks for permission, user
      // accepts, recording still doesn't start" only in release.
      await Future.delayed(const Duration(milliseconds: 400));
      return true;
    }

    if (status.isDenied && !status.isPermanentlyDenied) {
      return false;
    }

    if (status.isPermanentlyDenied) {
      showSettingDeniedDialog(Strings.microphoneAccessDenied.tr);
      return false;
    }

    return false;
  }

  /// Check if we have microphone permission.
  static Future<bool> hasPermission() async =>
      await Permission.microphone.isGranted;

  /// Start recording. Returns the file path that will be used, or null if failed.
  static Future<String?> startRecording() async {
    if (!await requestPermission()) return null;
    if (await recorder.isRecording()) return null;
    final Directory dir = await getTemporaryDirectory();
    final String name = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
    currentPath = '${dir.path}/$name';
    const RecordConfig config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 44100,
      numChannels: 1,
    );
    // Retry once after a short delay - same "OS says ready before it
    // actually is" gap requestPermission's delay guards against, kept
    // here too as defense in depth in case that delay wasn't enough on a
    // particular device.
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        await recorder.start(config, path: currentPath!);
        return currentPath;
      } catch (e) {
        if (attempt == 2) {
          currentPath = null;
          return null;
        }
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return null;
  }

  /// Stop recording and return the audio file, or null if failed/not recording.
  static Future<File?> stopRecording() async {
    if (!await recorder.isRecording() || currentPath == null) return null;
    try {
      await recorder.stop();
      final String? path = currentPath;
      currentPath = null;
      if (path == null) return null;
      final File file = File(path);
      return file.existsSync() ? file : null;
    } catch (_) {
      currentPath = null;
      return null;
    }
  }

  /// Cancel recording without saving.
  static Future<void> cancelRecording() async {
    if (await recorder.isRecording()) {
      await recorder.stop();
    }
    if (currentPath != null) {
      try {
        final File file = File(currentPath!);
        if (file.existsSync()) file.deleteSync();
      } catch (_) {}
      currentPath = null;
    }
  }

  static Future<bool> get isRecording => recorder.isRecording();

  /// Returns normalized amplitude [0.0, 1.0] from the current recording.
  /// -60 dBFS → 0.0, 0 dBFS → 1.0. Returns 0.0 if not recording.
  static Future<double> getAmplitudeNormalized() async {
    if (!await recorder.isRecording()) return 0.0;
    try {
      final amp = await recorder.getAmplitude();
      return ((amp.current + 60) / 60).clamp(0.0, 1.0);
    } catch (_) {
      return 0.0;
    }
  }

  /// Starts a live PCM16 LE mono stream at 16 kHz for live voice sessions.
  /// Returns a [Stream<Uint8List>] of raw PCM bytes, or null if permission
  /// is denied or another recording is already active.
  static Future<Stream<Uint8List>?> startPcmStream() async {
    if (!await requestPermission()) return null;
    if (await recorder.isRecording()) return null;
    const RecordConfig config = RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      sampleRate: 16000,
      numChannels: 1,
    );
    // Same first-grant retry as startRecording() - see requestPermission's
    // comment.
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        return await recorder.startStream(config);
      } catch (_) {
        if (attempt == 2) return null;
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return null;
  }

  /// Stops any active recording / stream without saving a file.
  static Future<void> stopStream() async {
    try {
      if (await recorder.isRecording()) await recorder.stop();
    } catch (_) {}
  }
}
