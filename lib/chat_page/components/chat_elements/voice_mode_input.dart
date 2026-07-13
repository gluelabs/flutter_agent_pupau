import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

// ── Voice phase ─────────────────────────────────────────────────────────────

enum _Phase { idle, listening, thinking, speaking }

_Phase _resolvePhase({
  required bool isRecording,
  required bool isStreaming,
  required bool isVoicePlaying,
}) {
  if (isVoicePlaying) return _Phase.speaking;
  if (isRecording) return _Phase.listening;
  if (isStreaming) return _Phase.thinking;
  return _Phase.idle;
}

// ── Rainbow palette (web spec: cyan→accent→violet→magenta→red→yellow) ───────

List<Color> _rainbowColors(Color accent) => [
      const Color(0xFF06B6D4),
      accent,
      const Color(0xFF7C3AED),
      const Color(0xFFEC4899),
      const Color(0xFFEF4444),
      const Color(0xFFFACC15),
      const Color(0xFF06B6D4), // close the loop
    ];

// ── Rainbow border + bloom painter ──────────────────────────────────────────
//
// Draws two layers around the card bounds:
//   1. Bloom  — the full rect filled with the gradient, blurred (behind the card)
//   2. Ring   — a crisp 2 px ring using the evenOdd path trick (in front of card)

class _RainbowRingPainter extends CustomPainter {
  const _RainbowRingPainter({
    required this.spinAngle,
    required this.bloomOpacity,
    required this.colors,
  });

  final double spinAngle;    // 0 → 2π, drives gradient rotation
  final double bloomOpacity; // 0.32 – 0.55 (breathing)
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    const double outerRadius = 18.0;
    const double borderWidth = 2.0;

    final SweepGradient gradient = SweepGradient(
      startAngle: spinAngle,
      endAngle: spinAngle + 2 * math.pi,
      colors: colors,
      tileMode: TileMode.repeated,
    );

    // ── 1. Bloom (behind card, blurred fill, breathing opacity) ──
    final Rect bloomRect = rect.inflate(3);
    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withValues(alpha: bloomOpacity),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(bloomRect, const Radius.circular(outerRadius + 3)),
      Paint()
        ..shader = gradient.createShader(bloomRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
    );
    canvas.restore();

    // ── 2. Crisp 2 px border ring ──
    final Path ringPath = Path()
      ..addRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(outerRadius)))
      ..addRRect(RRect.fromRectAndRadius(
          rect.deflate(borderWidth),
          const Radius.circular(outerRadius - borderWidth)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      ringPath,
      Paint()..shader = gradient.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RainbowRingPainter old) =>
      old.spinAngle != spinAngle || old.bloomOpacity != bloomOpacity;
}

// ── Orb background painter ───────────────────────────────────────────────────
//
// Draws two reactive layers inside the card (clipped to card bounds):
//   1. Resting glow  — thin blurred stroke along the inner border, always visible
//   2. Wavy band     — wider blurred stroke that grows with voice amplitude

class _OrbPainter extends CustomPainter {
  const _OrbPainter({
    required this.amplitude,
    required this.spinAngle,
    required this.colors,
    required this.phase,
  });

  final double amplitude;
  final double spinAngle;
  final List<Color> colors;
  final _Phase phase;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final double energy = amplitude.clamp(0.0, 1.0);
    final bool active =
        phase == _Phase.listening || phase == _Phase.speaking;

    final SweepGradient gradient = SweepGradient(
      startAngle: spinAngle,
      endAngle: spinAngle + 2 * math.pi,
      colors: colors,
    );

    // ── Resting glow (always) ──
    final Rect glowRect = rect.deflate(12);
    canvas.saveLayer(
      null,
      Paint()..color = Colors.white.withValues(
        alpha: active ? (0.34 + energy * 0.08).clamp(0.0, 0.42) : 0.22,
      ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(glowRect, const Radius.circular(8)),
      Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 + energy * 5.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.restore();

    // ── Wavy band (only when mic or speaker active + energy > floor) ──
    if (active && energy > 0.03) {
      final double bandWidth = 3.0 + energy * 26.0;
      final double blur = 6.0 + energy * 8.0;
      canvas.saveLayer(
        null,
        Paint()..color = Colors.white.withValues(
          alpha: (0.10 + energy * 0.40).clamp(0.0, 0.55),
        ),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            rect.deflate(bandWidth / 2 + 6), const Radius.circular(13)),
        Paint()
          ..shader = gradient.createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = bandWidth
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.amplitude != amplitude ||
      old.spinAngle != spinAngle ||
      old.phase != phase;
}

// ── Main widget (GetX reactive shell) ───────────────────────────────────────

class VoiceModeInput extends GetView<PupauChatController> {
  const VoiceModeInput({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    return Obx(() {
      final _Phase phase = _resolvePhase(
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
        child: _VoiceConsole(
          phase: phase,
          amplitude: amplitude,
          silenceProgress: silenceProgress,
          accentColor: accent,
          cardBg: cardBg,
          onExit: controller.toggleVoiceMode,
          onPtt: () => _handlePtt(phase),
          onCancel: controller.cancelRecording,
        ),
      );
    });
  }

  void _handlePtt(_Phase phase) {
    switch (phase) {
      case _Phase.idle:
        controller.startListeningNow();
      case _Phase.listening:
        controller.submitVoiceNow();
      case _Phase.thinking:
        controller.sendCancel();
      case _Phase.speaking:
        controller.stopAudioPlayback();
    }
  }
}

// ── Voice console card ───────────────────────────────────────────────────────
//
// Owns the spin (4.5s) and bloom (2.4s) AnimationControllers.
// The rainbow ring + bloom is a CustomPaint foreground painter so it draws
// on top of the card edge. The orb is painted inside the clipped card area.

class _VoiceConsole extends StatefulWidget {
  const _VoiceConsole({
    required this.phase,
    required this.amplitude,
    required this.silenceProgress,
    required this.accentColor,
    required this.cardBg,
    required this.onExit,
    required this.onPtt,
    required this.onCancel,
  });

  final _Phase phase;
  final double amplitude;
  final double silenceProgress;
  final Color accentColor;
  final Color cardBg;
  final VoidCallback onExit;
  final VoidCallback onPtt;
  final VoidCallback onCancel;

  @override
  State<_VoiceConsole> createState() => _VoiceConsoleState();
}

class _VoiceConsoleState extends State<_VoiceConsole>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _bloomCtrl;
  late final Animation<double> _bloomAnim;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();

    _bloomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _bloomAnim = Tween<double>(begin: 0.32, end: 0.55).animate(
      CurvedAnimation(parent: _bloomCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _bloomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = _rainbowColors(widget.accentColor);
    return AnimatedBuilder(
      animation: Listenable.merge([_spinCtrl, _bloomCtrl]),
      builder: (context, _) {
        final double angle = _spinCtrl.value * 2 * math.pi;
        final double bloom = _bloomAnim.value;
        return CustomPaint(
          // Bloom behind + ring on top of card edge
          painter: _RainbowRingPainter(
            spinAngle: angle,
            bloomOpacity: bloom,
            colors: colors,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: ColoredBox(
              color: widget.cardBg,
              child: Stack(
                children: [
                  // Reactive orb drawn above card background, behind content
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _OrbPainter(
                        amplitude: widget.amplitude,
                        spinAngle: angle,
                        colors: colors,
                        phase: widget.phase,
                      ),
                    ),
                  ),
                  // Console content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                    child: _ConsoleContent(
                      phase: widget.phase,
                      silenceProgress: widget.silenceProgress,
                      accentColor: widget.accentColor,
                      onPtt: widget.onPtt,
                      onCancel: widget.onCancel,
                      onExit: widget.onExit,
                    ),
                  ),
                  // Exit pill — bottom-right corner inside the card
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: _ExitPill(onTap: widget.onExit),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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

  final _Phase phase;
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
                child: phase == _Phase.listening
                    ? _CancelButton(key: const ValueKey('cancel'), onTap: onCancel)
                    : _VoiceBackButton(key: const ValueKey('back'), onTap: onExit),
              ),
            ),
            const SizedBox(width: 16),
            _PttButton(
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
              style: TextStyle(
                fontSize: 14,
                color: fg.withValues(alpha: 0.65),
              ),
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
  final _Phase phase;

  @override
  Widget build(BuildContext context) {
    final Color fg =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    final String text = switch (phase) {
      _Phase.idle => Strings.voiceIdle.tr,
      _Phase.listening => Strings.voiceListening.tr,
      _Phase.thinking => Strings.voiceThinking.tr,
      _Phase.speaking => Strings.voiceSpeaking.tr,
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

// ── PTT button ───────────────────────────────────────────────────────────────
//
// 72×72 circle, always accent-coloured.
// Sonar ring: expands from scale 0.9 → 1.9, fades to 0.
//   listening → 1.3 s, speaking → 1.6 s
// Breathing: scale 1.0 → 1.06 at 1.8 s (speaking only).

class _PttButton extends StatefulWidget {
  const _PttButton({
    required this.phase,
    required this.accentColor,
    required this.onTap,
  });

  final _Phase phase;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_PttButton> createState() => _PttButtonState();
}

class _PttButtonState extends State<_PttButton> with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _breatheCtrl;
  late final Animation<double> _breatheAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _breatheAnim = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _breatheCtrl, curve: Curves.easeInOut),
    );
    _syncAnimations();
  }

  @override
  void didUpdateWidget(_PttButton old) {
    super.didUpdateWidget(old);
    if (old.phase != widget.phase) _syncAnimations();
  }

  void _syncAnimations() {
    switch (widget.phase) {
      case _Phase.idle:
        _ringCtrl
          ..stop()
          ..reset();
        _breatheCtrl
          ..stop()
          ..reset();
      case _Phase.listening:
        _ringCtrl.duration = const Duration(milliseconds: 1300);
        if (!_ringCtrl.isAnimating) _ringCtrl.repeat();
        _breatheCtrl
          ..stop()
          ..reset();
      case _Phase.thinking:
        _ringCtrl
          ..stop()
          ..reset();
        _breatheCtrl
          ..stop()
          ..reset();
      case _Phase.speaking:
        _ringCtrl.duration = const Duration(milliseconds: 1600);
        if (!_ringCtrl.isAnimating) _ringCtrl.repeat();
        if (!_breatheCtrl.isAnimating) _breatheCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  IconData get _icon => switch (widget.phase) {
        _Phase.idle => Symbols.mic,
        _Phase.listening => Symbols.arrow_upward,
        _Phase.thinking => Symbols.stop,
        _Phase.speaking => Symbols.stop,
      };

  @override
  Widget build(BuildContext context) {
    final Color accent = widget.accentColor;
    final bool showRing = widget.phase == _Phase.listening ||
        widget.phase == _Phase.speaking;

    return AnimatedBuilder(
      animation: Listenable.merge([_ringCtrl, _breatheCtrl]),
      builder: (context, _) {
        // Sonar ring: scale 0.9 → 1.9, opacity 1 → 0
        final double ringProgress =
            Curves.easeOut.transform(_ringCtrl.value);
        final double ringScale = 0.9 + ringProgress * 1.0;
        final double ringOpacity = (1.0 - ringProgress).clamp(0.0, 1.0);
        final double btnScale = widget.phase == _Phase.speaking
            ? _breatheAnim.value
            : 1.0;

        return GestureDetector(
          onTap: widget.onTap,
          child: SizedBox(
            width: 92, // 72 + room for ring (inset: -5px each side → +10)
            height: 92,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sonar ring
                if (showRing)
                  Transform.scale(
                    scale: ringScale,
                    child: Opacity(
                      opacity: ringOpacity,
                      child: Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accent.withValues(alpha: 0.70),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                // PTT circle
                Transform.scale(
                  scale: btnScale,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.45),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        _icon,
                        key: ValueKey(widget.phase),
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Cancel button ─────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({super.key, required this.onTap});
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
          Symbols.close,
          size: 20,
          color: fg.withValues(alpha: 0.60),
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
