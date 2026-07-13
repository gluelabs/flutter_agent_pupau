import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:use_scramble/use_scramble.dart';

/// Asset bundled with the `flutter_agent_pupau` package.
const String sparkleSvgAsset = '${Constants.assetPath}/images/sparkle.svg';

/// Rotating “generating” phrases shown at the bottom of [ChatLoadingMessage]
/// (replaces the former jumping-dots loader and the removed input-area banner).
class LoadingPhrase extends StatefulWidget {
  const LoadingPhrase({
    super.key,

    /// When [ChatLoadingMessage] shows another loading row above this widget,
    /// use tighter top padding than the standalone phrase row.
    this.isStackedBelowPrimary = false,
  });

  final bool isStackedBelowPrimary;

  @override
  State<LoadingPhrase> createState() => _LoadingPhraseState();
}

class _LoadingPhraseState extends State<LoadingPhrase> {
  final PupauChatController _controller = Get.find<PupauChatController>();
  final Random _random = Random();
  Timer? _timer;
  int _phraseIndex = 0;

  List<String> _phrases() => Strings.generatingPhrases
      .map((String phraseKey) => phraseKey.tr)
      .toList(growable: false);

  void _startTimer() {
    _timer?.cancel();
    if (Strings.generatingPhrases.isEmpty) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        final int count = Strings.generatingPhrases.length;
        final int next = _random.nextInt(count);
        _phraseIndex = next == _phraseIndex ? (next + 1) % count : next;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void initState() {
    super.initState();
    final int count = Strings.generatingPhrases.length;
    _phraseIndex = count > 0 ? _random.nextInt(count) : 0;
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    return Obx(() {
      final bool isAnonymous = _controller.isAnonymous;
      final bool isLoadingConversation =
          _controller.isLoadingConversation.value;
      final double topPad = widget.isStackedBelowPrimary
          ? 0
          : (isLoadingConversation ? 40 : 6);
      final Color? textColor = isAnonymous
          ? AnonymousThemeColors.assistantText
          : MyStyles.getTextTheme(
              isLightTheme: !Get.isDarkMode,
            ).bodyMedium?.color;

      final List<String> phrases = _phrases();
      final String phrase = phrases.isEmpty
          ? ''
          : phrases[_phraseIndex % phrases.length];

      return Padding(
        padding: EdgeInsets.only(left: 16, top: topPad),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const _SparkleLoadingIcon(),
            const SizedBox(width: 6),
            Expanded(
              child: TextScramble(
                key: ValueKey<String>(phrase),
                text: phrase,
                chars: '!<>-_\\/[]{}—=+*^?#\$%£___',
                correctCharProbability: 0.2,
                scrambleCycles: 3,
                builder: (BuildContext context, String scrambledText) {
                  return Text(
                    scrambledText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// [sparkle.svg] tinted with [color], rotating continuously.
class _SparkleLoadingIcon extends StatefulWidget {
  const _SparkleLoadingIcon();

  @override
  State<_SparkleLoadingIcon> createState() => _SparkleLoadingIconState();
}

class _SparkleLoadingIconState extends State<_SparkleLoadingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    final Random random = Random();
    final double rotateSeconds = 1.35 + random.nextDouble() * 0.55;
    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (rotateSeconds * 1000).round().clamp(800, 4000),
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double size = DeviceService.isTablet ? 26 : 24;
    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: _rotateController,
        builder: (BuildContext context, Widget? child) {
          return Transform.rotate(
            angle: _rotateController.value * 2 * pi,
            child: SvgPicture.asset(
              sparkleSvgAsset,
              width: size,
              height: size,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                MyStyles.pupauTheme(!Get.isDarkMode).primary,
                BlendMode.srcIn,
              ),
            ),
          );
        },
      ),
    );
  }
}
