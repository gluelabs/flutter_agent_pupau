import 'package:flutter/material.dart';
import 'package:flutter_twemoji/flutter_twemoji.dart';

/// Drop-in replacement for [Text] that renders Unicode emoji as bundled
/// Twemoji images instead of relying on the device's emoji font glyph.
///
/// Font-fallback emoji rendering has repeatedly broken glyph rendering for
/// *all* text (not just emoji) on at least one tested environment — see
/// [EmojiSyntax], which solves this the same way for markdown content. This
/// widget gives plain, non-markdown labels (assistant name/description,
/// conversation starters, etc.) the same working emoji rendering.
///
/// Uses `WidgetSpan(alignment: middle)` with no extra padding around each
/// emoji glyph — deliberately not `PlaceholderAlignment.baseline`, which
/// miscalculates line ascent for spans taller than the surrounding line and
/// causes wrapped lines to overlap (see the fix in `link_builder.dart`).
class EmojiText extends StatelessWidget {
  const EmojiText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    final double size =
        DefaultTextStyle.of(context).style.merge(style).fontSize ?? 14;
    final List<InlineSpan> spans = [];

    text.splitMapJoin(
      TwemojiUtils.emojiRegex,
      onMatch: (Match match) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Twemoji(
              emoji: match[0] ?? '',
              height: size,
              width: size,
              twemojiFormat: TwemojiFormat.png,
            ),
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch));
        return '';
      },
    );

    return Text.rich(
      TextSpan(style: style, children: spans),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      softWrap: softWrap,
    );
  }
}
