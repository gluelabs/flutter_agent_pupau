import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/voice_console_card.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Standard (non-voice-mode) audio message recording. Replaces the entire
/// input area the same way [VoiceModeInput] does, using the same console
/// design — just with a duration readout instead of a phase label, and no
/// silence countdown / exit pill (cancel already returns to text mode).
class RecordingConsole extends GetView<PupauChatController> {
  const RecordingConsole({super.key});

  String _formatDuration(Duration d) {
    final int m = d.inMinutes;
    final int s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      final Duration duration = controller.recordingDuration.value;
      final Color accent = isAnonymous
          ? Colors.black
          : MyStyles.pupauTheme(!Get.isDarkMode).primary;
      final Color cardBg = Theme.of(context).scaffoldBackgroundColor;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: VoiceConsoleCard(
          phase: VoiceConsolePhase.listening,
          amplitude: 0.0,
          accentColor: accent,
          cardBg: cardBg,
          child: _RecordingContent(
            durationLabel: _formatDuration(duration),
            accentColor: accent,
            onCancel: controller.cancelRecording,
            onSend: controller.stopAndSendRecording,
          ),
        ),
      );
    });
  }
}

class _RecordingContent extends StatelessWidget {
  const _RecordingContent({
    required this.durationLabel,
    required this.accentColor,
    required this.onCancel,
    required this.onSend,
  });

  final String durationLabel;
  final Color accentColor;
  final VoidCallback onCancel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final Color fg =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Duration readout, same slot/style as voice mode's status label
        Center(
          child: Text(
            durationLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: fg.withValues(alpha: 0.72),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Action row: [cancel] [send] [mirror spacer]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: ConsoleCancelButton(onTap: onCancel),
            ),
            const SizedBox(width: 16),
            ConsoleMainButton(
              phase: VoiceConsolePhase.listening,
              accentColor: accentColor,
              onTap: onSend,
            ),
            const SizedBox(width: 16),
            const SizedBox(width: 40), // mirror spacer keeps button centered
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
