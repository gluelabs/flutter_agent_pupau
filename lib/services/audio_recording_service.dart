import 'dart:developer';
import 'dart:io';
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

    if (status.isGranted) return true;

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
    try {
      final Directory dir = await getTemporaryDirectory();
      final String name = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      currentPath = '${dir.path}/$name';
      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: currentPath!,
      );
      return currentPath;
    } catch (e) {
      return null;
    }
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
      inspect(file);
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
}
