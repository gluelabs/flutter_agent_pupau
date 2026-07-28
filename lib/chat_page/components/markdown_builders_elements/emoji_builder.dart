import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_twemoji/flutter_twemoji.dart';
import 'package:markdown/markdown.dart' as md;

/// Renders an `emoji` element (see [EmojiSyntax]) as a bundled Twemoji PNG,
/// inline with the rest of the paragraph.
///
/// Returned as a [Text.rich]/[WidgetSpan] rather than a bare [Twemoji]
/// widget: `flutter_markdown_plus` only folds consecutive pieces it
/// recognizes as *text* (`Text`/`SelectableText`/`RichText`) into one
/// continuous [TextSpan] — anything else becomes its own separate [Wrap]
/// child, splitting the paragraph into independent "before" / "emoji" /
/// "after" blocks. [Wrap] places each child atomically, so if the "after"
/// block doesn't fit the small leftover space next to the emoji on that
/// line, the *whole* block jumps to a new line instead of wrapping
/// word-by-word. Wrapping the emoji in [Text.rich] makes it merge into the
/// same [TextSpan] as the surrounding words, so it flows like a real inline
/// glyph.
class EmojiBuilder extends MarkdownElementBuilder {
  EmojiBuilder();

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final String emoji = element.attributes['value'] ?? '';
    if (emoji.isEmpty) return null;
    final double size = (preferredStyle ?? parentStyle)?.fontSize ?? 16;
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Twemoji(
          emoji: emoji,
          height: size,
          width: size,
          twemojiFormat: TwemojiFormat.png,
        ),
      ),
    );
  }
}
