import 'package:flutter_twemoji/flutter_twemoji.dart';
import 'package:markdown/markdown.dart' as md;

/// Matches a Unicode emoji sequence and turns it into an `emoji` element so
/// [EmojiBuilder] can render it as a bundled Twemoji image instead of
/// relying on the device's font glyph for it.
///
/// This exists because rendering emoji via font fallback (fontFamilyFallback
/// pointing at the platform's color-emoji font) has repeatedly broken glyph
/// rendering for *all* text, not just emoji, on at least one tested
/// environment — an image-based renderer sidesteps font/glyph resolution
/// for emoji entirely, and never touches how regular text is styled.
class EmojiSyntax extends md.InlineSyntax {
  EmojiSyntax() : super(TwemojiUtils.emojiRegex.pattern);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final md.Element element = md.Element.withTag('emoji');
    element.attributes['value'] = match[0] ?? '';
    parser.addNode(element);
    return true;
  }
}
