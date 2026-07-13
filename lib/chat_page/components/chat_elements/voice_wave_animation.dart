import 'dart:math' as math;
import 'package:flutter/material.dart';

class VoiceWaveAnimation extends StatefulWidget {
  const VoiceWaveAnimation({
    super.key,
    required this.amplitude,
    required this.color,
    this.barCount = 7,
  });

  final double amplitude;
  final Color color;
  final int barCount;

  @override
  State<VoiceWaveAnimation> createState() => _VoiceWaveAnimationState();
}

class _VoiceWaveAnimationState extends State<VoiceWaveAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(widget.barCount, (i) {
              final double phase = i / widget.barCount;
              final double t = (_controller.value + phase) % 1.0;
              final double sine = math.sin(t * 2 * math.pi);
              const double minH = 4.0;
              const double maxH = 28.0;
              final double height =
                  minH + (maxH * widget.amplitude * (sine + 1) / 2);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 4,
                height: height.clamp(minH, maxH + minH),
                decoration: BoxDecoration(
                  color: widget.color.withValues(
                    alpha: (0.5 + 0.5 * widget.amplitude).clamp(0.0, 1.0),
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
