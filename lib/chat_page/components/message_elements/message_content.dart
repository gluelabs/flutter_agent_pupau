import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/audio_converting_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/context_info_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_body.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_sender_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/message_time_info.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/prompt_options_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/reflection_tag_container.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/models/prompt_option_model.dart';
import 'package:flutter_agent_pupau/models/prompt_reflection_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/string_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:material_symbols_icons/symbols.dart';

class MessageContent extends StatelessWidget {
  const MessageContent({
    super.key,
    required this.messageId,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.isAssistant,
    required this.isAnonymous,
    this.assistant,
    this.contextInfo,
    this.grounding,
    this.isAudioInput = false,
    this.onRegisterUserBubbleToggle,
    this.userBubbleExpandTap,
  });

  final String messageId;
  final String message;
  final MessageStatus status;
  final DateTime? createdAt;
  final bool isAssistant;
  final bool isAnonymous;
  final Assistant? assistant;
  final ContextInfo? contextInfo;
  final GroundingInfo? grounding;
  final bool isAudioInput;

  /// When non-null and [isAssistant] is false, the child registers a toggle
  /// callback so [MessageBubble] can track expand availability.
  final void Function(VoidCallback? toggleExpand)? onRegisterUserBubbleToggle;

  /// When set (user message, expandable), the bubble column is wrapped in a tap
  /// handler so the whole bubble (including the time/chevron row) toggles.
  final VoidCallback? userBubbleExpandTap;

  @override
  Widget build(BuildContext context) {
    final List<PromptOption> options = isAssistant
        ? TagService.extractOptions(message, messageId)
        : <PromptOption>[];
    final bool hasOptionsTag =
        TagService.hasOptionsClosingTag(message) && isAssistant;
    final bool hasReflectionTag =
        TagService.hasReflectionClosingTag(message) && isAssistant;
    final PromptReflection? reflection = hasReflectionTag
        ? TagService.extractReflection(message, messageId)
        : null;
    final bool isLoading =
        status == MessageStatus.loading && message.trim().isEmpty;
    final String bodyMessage = isAssistant && TagService.hasThinkingTag(message)
        ? TagService.stripThinkingForMarkdown(message)
        : message;
    final bool isAudioTranscribing =
        !isAssistant &&
        isAudioInput &&
        message.trim().isEmpty &&
        status == MessageStatus.sent;
    if (isAudioTranscribing) {
      return AudioConvertingInfo(
        isAnonymous: isAnonymous,
        createdAt: createdAt,
      );
    }
    if (isLoading) return const SizedBox();

    if (!isAssistant) {
      return _UserExpandableMessageColumn(
        messageId: messageId,
        message: message,
        isAnonymous: isAnonymous,
        createdAt: createdAt,
        contextInfo: contextInfo,
        onRegisterUserBubbleToggle: onRegisterUserBubbleToggle,
        userBubbleExpandTap: userBubbleExpandTap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        MessageSenderInfo(assistant: assistant),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            MessageBody(
              messageId: messageId,
              message: bodyMessage,
              isFromAssistant: true,
              isAnonymous: isAnonymous,
              grounding: grounding,
            ),
          ],
        ),
        if (hasOptionsTag && options.isNotEmpty)
          PromptOptionsList(options: options),
        if (hasReflectionTag &&
            reflection != null &&
            reflection.text.isNotEmpty)
          ReflectionTagContainer(reflection: reflection),
        if (contextInfo != null)
          ContextInfoContainer(contextInfo: contextInfo!),
      ],
    );
  }
}

class _UserExpandableMessageColumn extends StatefulWidget {
  const _UserExpandableMessageColumn({
    required this.messageId,
    required this.message,
    required this.isAnonymous,
    required this.createdAt,
    this.contextInfo,
    this.onRegisterUserBubbleToggle,
    this.userBubbleExpandTap,
  });

  final String messageId;
  final String message;
  final bool isAnonymous;
  final DateTime? createdAt;
  final ContextInfo? contextInfo;
  final void Function(VoidCallback? toggleExpand)? onRegisterUserBubbleToggle;
  final VoidCallback? userBubbleExpandTap;

  @override
  State<_UserExpandableMessageColumn> createState() =>
      _UserExpandableMessageColumnState();
}

class _UserExpandableMessageColumnState
    extends State<_UserExpandableMessageColumn> {
  bool _expanded = false;
  bool? _lastRegisteredShowToggle;

  @override
  void didUpdateWidget(covariant _UserExpandableMessageColumn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _expanded = false;
      _lastRegisteredShowToggle = null;
    }
  }

  TextStyle _measureStyle() {
    final bool isTablet = DeviceService.isTablet;
    return TextStyle(
      fontSize: isTablet ? 17 : 15,
      color: widget.isAnonymous
          ? AnonymousThemeColors.userText
          : MyStyles.getTextTheme(isLightTheme: true).bodyMedium?.color,
    );
  }

  Color _chevronColor() {
    return widget.isAnonymous
        ? AnonymousThemeColors.userText
        : (MyStyles.getTextTheme(isLightTheme: true).bodyMedium?.color)!;
  }

  bool _exceedsTwoLines(double maxWidth, TextDirection textDirection) {
    if (maxWidth <= 0 || !maxWidth.isFinite) return false;
    final String converted = TagService.convertTags(widget.message);
    final String measureText = StringService.fixMarkdownNewLines(converted);
    final TextPainter painter = TextPainter(
      text: TextSpan(text: measureText, style: _measureStyle()),
      textDirection: textDirection,
      maxLines: 2,
    )..layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  void _registerBubbleTap(bool showToggle) {
    if (_lastRegisteredShowToggle == showToggle) return;
    _lastRegisteredShowToggle = showToggle;
    final VoidCallback? fn = showToggle
        ? () {
            setState(() {
              _expanded = !_expanded;
            });
          }
        : null;
    widget.onRegisterUserBubbleToggle?.call(fn);
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection textDirection = Directionality.of(context);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double screenW = MediaQuery.sizeOf(context).width;
        // [Row] + [Flexible] often gives an unbounded maxWidth; use the same
        // horizontal budget as [MessageElements] (left gutter ~15% of screen).
        final double fallbackMaxW = screenW * 0.82;
        final double maxWidth =
            constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite &&
                constraints.maxWidth > 0
            ? min(constraints.maxWidth, fallbackMaxW)
            : fallbackMaxW;

        final bool showToggle = _exceedsTwoLines(maxWidth, textDirection);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          _registerBubbleTap(showToggle);
        });

        final TextPainter linePainter = TextPainter(
          text: TextSpan(text: ' ', style: _measureStyle()),
          textDirection: textDirection,
        )..layout(maxWidth: maxWidth);
        final double lineHeight = linePainter.preferredLineHeight;
        // Tight height + scroll viewport clips tall markdown without flex overflow.
        final double collapsedMaxHeight = lineHeight * 2 + 8;

        // Long user bubbles: selection on markdown steals/defers taps from the
        // expand [GestureDetector]; omit [SelectionArea] for those.
        final bool wrapWithSelectionArea = !showToggle;
        final Widget markdown = MessageBody(
          messageId: widget.messageId,
          message: widget.message,
          isFromAssistant: false,
          isAnonymous: widget.isAnonymous,
          wrapInFlexible: false,
          wrapWithSelectionArea: wrapWithSelectionArea,
        );

        // Expandable messages need a bounded width so wrapping matches
        // [_exceedsTwoLines]; short bubbles stay intrinsic (no forced max width).
        final Widget markdownAtMaxWidth = Align(
          alignment: Alignment.topRight,
          child: SizedBox(width: maxWidth, child: markdown),
        );
        final Widget markdownIntrinsic = Align(
          alignment: Alignment.topRight,
          widthFactor: 1.0,
          heightFactor: 1.0,
          child: markdown,
        );

        // Clip without [Scrollable]: avoids scroll vs tap arena delay on taps.
        final Widget markdownBlock = showToggle && !_expanded
            ? SizedBox(
                height: collapsedMaxHeight,
                width: maxWidth,
                child: ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topRight,
                    minWidth: maxWidth,
                    maxWidth: maxWidth,
                    minHeight: 0,
                    maxHeight: double.infinity,
                    child: markdown,
                  ),
                ),
              )
            : showToggle
            ? markdownAtMaxWidth
            : markdownIntrinsic;

        Widget column = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            AnimatedSize(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeInOut,
              alignment: Alignment.topRight,
              child: markdownBlock,
            ),
            if (widget.contextInfo != null)
              ContextInfoContainer(contextInfo: widget.contextInfo!),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MessageTimeInfo(
                    localDate: widget.createdAt?.toLocal(),
                    isAssistant: false,
                  ),
                  if (showToggle) ...<Widget>[
                    const SizedBox(width: 8),
                    Transform.translate(
                      offset: Offset(0, 4),
                      child: Icon(
                        _expanded ? Symbols.expand_less : Symbols.expand_more,
                        size: 22,
                        color: _chevronColor(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );

        if (widget.userBubbleExpandTap != null) {
          column = GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.userBubbleExpandTap,
            child: column,
          );
        }

        return column;
      },
    );
  }
}
