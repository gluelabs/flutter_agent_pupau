import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/voice_console_card.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

VoiceConsolePhase _resolvePhase({
  required bool isRecording,
  required bool isStreaming,
  required bool isVoicePlaying,
}) {
  if (isVoicePlaying) return VoiceConsolePhase.speaking;
  if (isRecording) return VoiceConsolePhase.listening;
  if (isStreaming) return VoiceConsolePhase.thinking;
  return VoiceConsolePhase.idle;
}

// ── Main widget (GetX reactive shell) ───────────────────────────────────────

class VoiceModeInput extends GetView<PupauChatController> {
  const VoiceModeInput({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      final VoiceConsolePhase phase = _resolvePhase(
        isRecording: controller.isRecording.value,
        isStreaming: controller.isStreaming.value,
        isVoicePlaying: controller.isVoicePlaying.value,
      );
      final double amplitude = controller.voiceAmplitude.value;
      final double silenceProgress = controller.voiceSilenceProgress.value;
      final Color accent = isAnonymous
          ? Colors.black
          : MyStyles.pupauTheme(!Get.isDarkMode).primary;
      final Color cardBg = Theme.of(context).scaffoldBackgroundColor;

      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: VoiceConsoleCard(
          phase: phase,
          amplitude: amplitude,
          accentColor: accent,
          cardBg: cardBg,
          overlay: _ExitPill(onTap: controller.toggleVoiceMode),
          child: _ConsoleContent(
            phase: phase,
            silenceProgress: silenceProgress,
            accentColor: accent,
            onPtt: () => _handlePtt(phase),
            onCancel: controller.cancelRecording,
            onExit: controller.toggleVoiceMode,
          ),
        ),
      );
    });
  }

  void _handlePtt(VoiceConsolePhase phase) {
    switch (phase) {
      case VoiceConsolePhase.idle:
        controller.startListeningNow();
      case VoiceConsolePhase.listening:
        controller.submitVoiceNow();
      case VoiceConsolePhase.thinking:
        controller.sendCancel();
      case VoiceConsolePhase.speaking:
        controller.stopAudioPlayback();
    }
  }
}

// ── Console content layout ───────────────────────────────────────────────────

class _ConsoleContent extends StatelessWidget {
  const _ConsoleContent({
    required this.phase,
    required this.silenceProgress,
    required this.accentColor,
    required this.onPtt,
    required this.onCancel,
    required this.onExit,
  });

  final VoiceConsolePhase phase;
  final double silenceProgress;
  final Color accentColor;
  final VoidCallback onPtt;
  final VoidCallback onCancel;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status label
        Center(child: _StatusLabel(phase: phase)),
        const SizedBox(height: 14),
        // PTT row: [cancel] [ptt] [mirror spacer]
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: phase == VoiceConsolePhase.listening
                    ? ConsoleCancelButton(
                        key: const ValueKey('cancel'),
                        onTap: onCancel,
                      )
                    : _VoiceBackButton(
                        key: const ValueKey('back'),
                        onTap: onExit,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            ConsoleMainButton(
              phase: phase,
              accentColor: accentColor,
              onTap: onPtt,
            ),
            const SizedBox(width: 16),
            const SizedBox(width: 40), // mirror spacer keeps PTT centered
          ],
        ),
        const SizedBox(height: 14),
        // Silence countdown bar — only visible when countdown is active
        _SilenceCountdownBar(
          progress: silenceProgress,
          accentColor: accentColor,
        ),
        const SizedBox(height: 2),
      ],
    );
  }
}

// ── Exit pill ────────────────────────────────────────────────────────────────

class _ExitPill extends StatelessWidget {
  const _ExitPill({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg =
        Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.keyboard, size: 18, color: fg.withValues(alpha: 0.65)),
            const SizedBox(width: 4),
            Text(
              Strings.text.tr,
              style: TextStyle(fontSize: 14, color: fg.withValues(alpha: 0.65)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status label ─────────────────────────────────────────────────────────────

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.phase});
  final VoiceConsolePhase phase;

  @override
  Widget build(BuildContext context) {
    final Color fg =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final String text = switch (phase) {
      VoiceConsolePhase.idle => Strings.voiceIdle.tr,
      VoiceConsolePhase.listening => Strings.voiceListening.tr,
      VoiceConsolePhase.thinking => Strings.voiceThinking.tr,
      VoiceConsolePhase.speaking => Strings.voiceSpeaking.tr,
    };
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: Text(
        text,
        key: ValueKey(phase),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: fg.withValues(alpha: 0.72),
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────

class _VoiceBackButton extends StatelessWidget {
  const _VoiceBackButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fg.withValues(alpha: 0.08),
        ),
        child: Icon(
          Symbols.arrow_back,
          size: 20,
          color: fg.withValues(alpha: 0.60),
        ),
      ),
    );
  }
}

// ── Silence countdown bar ─────────────────────────────────────────────────────
//
// 4 px tall, 110 px wide track. Appears only when silence countdown is running
// (progress > 0). Fill scales from left via FractionallySizedBox.

class _SilenceCountdownBar extends StatelessWidget {
  const _SilenceCountdownBar({
    required this.progress,
    required this.accentColor,
  });

  final double progress;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: progress > 0.0 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 150),
      child: SizedBox(
        width: 110,
        height: 4,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              // Track
              Container(color: accentColor.withValues(alpha: 0.16)),
              // Fill (left-anchored)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(color: accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
