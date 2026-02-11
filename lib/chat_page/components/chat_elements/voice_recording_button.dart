import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class VoiceRecordingButton extends GetView<ChatController> {
  const VoiceRecordingButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        bool hasText = controller.inputMessage.value.trim().isNotEmpty;
        bool isAnonymous = controller.isAnonymous;
        bool isEnabled = !controller.hasApiError.value && !controller.stopIsActive();
        return _AnimatedMicButton(
          hasText: hasText,
          isEnabled: isEnabled,
          isAnonymous: isAnonymous,
          onPressed: () => controller.startRecording(),
        );
      },
    );
  }
}

class _AnimatedMicButton extends StatefulWidget {
  const _AnimatedMicButton({
    required this.hasText,
    required this.isEnabled,
    required this.isAnonymous,
    required this.onPressed,
  });

  final bool hasText;
  final bool isEnabled;
  final bool isAnonymous;
  final VoidCallback onPressed;

  @override
  State<_AnimatedMicButton> createState() => _AnimatedMicButtonState();
}

class _AnimatedMicButtonState extends State<_AnimatedMicButton>
    with SingleTickerProviderStateMixin {
  static const Duration _duration = Duration(milliseconds: 250);
  static const Curve _curve = Curves.easeInOutCubic;

  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _duration, vsync: this);
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.2, 0), // Slide out to the right when disappearing
    ).animate(CurvedAnimation(parent: _controller, curve: _curve));
    if (widget.hasText) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_AnimatedMicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasText != oldWidget.hasText) {
      if (widget.hasText) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseOpacity = widget.isEnabled ? 1.0 : 0.5;
    final fade = Tween<double>(begin: baseOpacity, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: _curve),
    );
    return IgnorePointer(
      ignoring: widget.hasText,
      child: SlideTransition(
        position: _slide,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _curve.transform(_controller.value);
            return FadeTransition(
              opacity: fade,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (bounds) {
                  final rect = Rect.fromLTWH(0, 0, bounds.width, bounds.height);
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: const [Color(0x00000000), Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
                    stops: [0.0, t, 1.0],
                  ).createShader(rect);
                },
                child: child,
              ),
            );
          },
          child: IconButton(
            icon: Icon(
              Symbols.mic,
              size: 26,
              color: widget.isAnonymous
                  ? Colors.black
                  : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
            ),
            onPressed: widget.isEnabled ? widget.onPressed : null,
            tooltip: Strings.recordAudio.tr,
          ),
        ),
      ),
    );
  }
}
