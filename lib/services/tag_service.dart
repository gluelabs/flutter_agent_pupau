import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/prompt_option_model.dart';
import 'package:flutter_agent_pupau/models/prompt_reflection_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_thinking_data.dart';
import 'package:flutter_agent_pupau/models/user_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/google_maps_service.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:markdown/markdown.dart' as md;

class TagService {
  static const String assistantOpeningTag = "<assistant id=";
  static const String assistantClosingTag = "</assistant>";
  static const String optionsOpeningTag = "<options>";
  static const String optionsClosingTag = "</options>";
  static const String reflectionOpeningTag = "<reflection>";
  static const String reflectionClosingTag = "</reflection>";
  static const String userNameTag = "[USER_NAME]";
  static const String thinkingOpeningTag = "<thinking>";
  static const String thinkingClosingTag = "</thinking>";
  static RegExp thinkingRegex = RegExp(
    r'<thinking>([\s\S]*?)(?:<\/thinking>)',
    multiLine: true,
  );
  static RegExp optionsRegex = RegExp(r'<options>.*?</options>', dotAll: true);
  static RegExp reflectionRegex = RegExp(
    r'<reflection>.*?</reflection>',
    dotAll: true,
  );
  static const String mapTag = "<map";
  static RegExp mapRegex = RegExp(r'<map[^>]*?></map>', dotAll: true);
  static const String mermaidClosingTag = "</mermaid-graph>";
  static const String mermaidOpeningTag = "<mermaid-graph";
  static RegExp mermaidRegex = RegExp(
    r'<mermaid-graph[^>]*?>([\s\S]*?)</mermaid-graph>',
    dotAll: true,
    multiLine: true,
  );
  static RegExp mermaidOpeningRegex = RegExp(r'<mermaid-graph[^>]*?>');
  static RegExp downloadRegex = RegExp(
    r'<download\s+format="([^"]*)"\s+id="([^"]*)">\s*([^<]*?)\s*</download>',
    dotAll: true,
    multiLine: true,
  );

  static String convertTags(String message) => formatMermaidCode(
    convertAssistantTag(
      thinkingTagNewLinesRemover(
        message,
      ).replaceAll(optionsRegex, '').replaceAll(reflectionRegex, ''),
    ),
  );

  // Options Tag

  static bool hasOptionsClosingTag(String message) =>
      message.contains(optionsOpeningTag) &&
      message.contains(optionsClosingTag);

  static List<PromptOption> extractOptions(String text, String messageId) {
    if (!hasOptionsClosingTag(text)) return [];

    List<PromptOption> options = [];

    // Extract the content between <options> and </options>
    final optionsMatch = RegExp(
      r'<options>(.*?)</options>',
      dotAll: true,
    ).firstMatch(text);

    if (optionsMatch != null) {
      String optionsContent = optionsMatch.group(1) ?? '';

      // Extract all the options
      RegExp optionRegex = RegExp(
        r'<option\s+prompt="([^"]*)">(.*?)</option>',
        dotAll: true,
      );

      for (RegExpMatch match in optionRegex.allMatches(optionsContent)) {
        options.add(
          PromptOption(
            messageId: messageId,
            prompt: match.group(1) ?? '',
            text: match.group(2)?.trim() ?? '',
          ),
        );
      }
    }

    return options;
  }

  // Reflection Tag

  static bool hasReflectionClosingTag(String message) =>
      message.contains(reflectionOpeningTag) &&
      message.contains(reflectionClosingTag);

  static PromptReflection? extractReflection(String text, String messageId) {
    if (!hasReflectionClosingTag(text)) return null;

    // Extract the content between <reflection> and </reflection>
    final reflectionMatch = RegExp(
      r'<reflection>(.*?)</reflection>',
      dotAll: true,
    ).firstMatch(text);

    if (reflectionMatch != null) {
      String reflectionContent = reflectionMatch.group(1) ?? '';

      // Extract the reflection

      String text = reflectionContent.split('<evaluation')[0].trim();

      // Extract the evaluation result
      final evaluationMatch = RegExp(
        r'<evaluation\s+result="(POSITIVE|NEGATIVE)"/>',
      ).firstMatch(reflectionContent);

      String evaluation = evaluationMatch?.group(1) ?? '';

      return PromptReflection(
        messageId: messageId,
        text: text,
        evaluation: evaluation,
      );
    }
    return null;
  }

  // UserName Tag

  static String addUserNameTag(String message) {
    final User? user = PupauSharedPreferences.getUser();
    final String? userName = user?.name;
    if (userName == null) return message.replaceAll(userNameTag, "");
    return message.replaceAll(userNameTag, userName);
  }

  // Assistant Tag

  static String getAssistantTag(Assistant assistant) =>
      "<assistant id=\"${assistant.id}\" type=\"${AssistantService.getAssistantTypeString(assistant.type)}\" name=\"${assistant.name}\">${assistant.name}</assistant>";

  static bool hasAssistantTag(String message) =>
      message.contains(assistantOpeningTag) &&
      message.contains(assistantClosingTag);

  static String convertAssistantTag(String message) {
    if (hasAssistantTag(message)) {
      int openingStartIndex = message.indexOf(assistantOpeningTag);
      int closingStartIndex = message.indexOf(assistantClosingTag);
      int openingEndIndex = message.indexOf(">", openingStartIndex) + 1;
      int closingEndIndex = message.indexOf(">", closingStartIndex) + 1;
      String tagString = message.substring(openingEndIndex, closingStartIndex);
      tagString = "**@$tagString**";
      String messageWithTag = message.replaceRange(
        openingStartIndex,
        closingEndIndex,
        tagString,
      );
      if (hasAssistantTag(messageWithTag)) {
        return convertAssistantTag(messageWithTag);
      }
      return messageWithTag;
    }
    return message;
  }

  // Google Map Tag

  static GoogleMapData extractMapInfo(String message) {
    if (!message.contains(mapTag)) return GoogleMapData();

    // Find the map tag in the message
    int startIndex = message.indexOf(mapTag);
    int endIndex = message.indexOf("</map>", startIndex);
    if (endIndex == -1) return GoogleMapData();

    // Extract coordinates if lat/long format
    RegExp latLongRegex = RegExp(r'lat="([^"]*)".*long="([^"]*)"');
    RegExpMatch? latLongMatch = latLongRegex.firstMatch(message);
    if (latLongMatch != null) {
      return GoogleMapData(
        position: LatLng(
          latitude: double.parse(latLongMatch.group(1) ?? "0"),
          longitude: double.parse(latLongMatch.group(2) ?? "0"),
        ),
      );
    }

    // Extract address if address format
    RegExp addressRegex = RegExp(r'address="([^"]*)"');
    RegExpMatch? addressMatch = addressRegex.firstMatch(message);
    if (addressMatch != null) {
      return GoogleMapData(address: addressMatch.group(1) ?? "");
    }
    return GoogleMapData();
  }

  // Mermaid Tag

  static String formatMermaidCode(String message) {
    // Check if message contains mermaid tags
    if (!message.contains(mermaidOpeningTag) ||
        !message.contains(mermaidClosingTag)) {
      return message;
    }

    // Use a more reliable approach to process one tag at a time
    List<String> parts = [];
    int currentPosition = 0;

    while (currentPosition < message.length) {
      // Find the start of the next mermaid graph
      int startTag = message.indexOf(mermaidOpeningTag, currentPosition);

      // If no more tags, add the remaining text and break
      if (startTag == -1) {
        parts.add(message.substring(currentPosition));
        break;
      }

      // Add the text before the tag
      if (startTag > currentPosition) {
        parts.add(message.substring(currentPosition, startTag));
      }

      // Find the end of the opening tag
      int endOpenTag = message.indexOf('>', startTag);
      if (endOpenTag == -1) {
        // Invalid tag format - just add the rest and break
        parts.add(message.substring(currentPosition));
        break;
      }
      endOpenTag++; // Include the '>' character

      // Find the matching closing tag
      int closeTag = message.indexOf(mermaidClosingTag, endOpenTag);
      if (closeTag == -1) {
        // No closing tag - just add the rest and break
        parts.add(message.substring(currentPosition));
        break;
      }

      // Extract the tag contents
      String tagContent = message.substring(endOpenTag, closeTag);

      // Format the content - replace newlines with placeholder
      String formattedContent = tagContent.replaceAll(
        RegExp(r'\r\n|\r|\n'),
        '<line-break>',
      );

      // Add the formatted tag
      parts.add('$mermaidOpeningTag$formattedContent$mermaidClosingTag');

      // Move past this tag
      currentPosition = closeTag + mermaidClosingTag.length;
    }

    // Join all parts back together
    return parts.join('');
  }

  static String cleanMermaidCode(String message) => message
      .replaceAll(mermaidOpeningRegex, '')
      .replaceAll(mermaidClosingTag, '')
      .replaceAll('<line-break>', '\n')
      .trim();

  // Thinking Tag

  static bool hasThinkingTag(String message) =>
      message.contains(thinkingOpeningTag);

  static String thinkingTagNewLinesRemover(String message) {
    if (!message.contains(thinkingOpeningTag) ||
        !message.contains(thinkingClosingTag)) {
      return message;
    }
    return message.replaceAllMapped(thinkingRegex, (match) {
      String content = match.group(1) ?? '';
      return '$thinkingOpeningTag${content.replaceAll(RegExp(r'\r\n|\r|\n'), '<line-break>')}$thinkingClosingTag';
    });
  }

  static final RegExp _closedThinkingBlockRegex = RegExp(
    r'<thinking>[\s\S]*?</thinking>',
    multiLine: true,
  );

  /// Each `<thinking>…</thinking>` block in order, plus a trailing open block during SSE.
  ///
  /// [ThinkingTagSegment.blockIndex] is 1-based (`_thinking_1`, `_thinking_2`, …).
  static List<ThinkingTagSegment> enumerateThinkingTagSegments(String message) {
    if (!hasThinkingTag(message)) {
      return <ThinkingTagSegment>[];
    }

    final List<ThinkingTagSegment> segments = <ThinkingTagSegment>[];
    int blockIndex = 0;
    int searchEnd = 0;

    for (final RegExpMatch match in _closedThinkingBlockRegex.allMatches(message)) {
      blockIndex++;
      segments.add(
        ThinkingTagSegment(
          blockIndex: blockIndex,
          rawSegment: match.group(0) ?? '',
        ),
      );
      searchEnd = match.end;
    }

    final String tail = message.substring(searchEnd);
    final int openIndex = tail.indexOf(thinkingOpeningTag);
    if (openIndex >= 0) {
      blockIndex++;
      segments.add(
        ThinkingTagSegment(
          blockIndex: blockIndex,
          rawSegment: tail.substring(openIndex),
          isOpen: true,
        ),
      );
    }

    return segments;
  }

  /// Adjacent `<thinking>` blocks (only whitespace between) merged into one segment.
  ///
  /// Used for inline-thinking tool rows: one bubble per consecutive run.
  static List<ThinkingTagSegment> groupedConsecutiveThinkingTagSegments(
    String message,
  ) {
    if (!hasThinkingTag(message)) {
      return <ThinkingTagSegment>[];
    }

    final List<({int start, int end, String raw, bool isOpen})> blocks =
        <({int start, int end, String raw, bool isOpen})>[];
    int searchEnd = 0;

    for (final RegExpMatch match in _closedThinkingBlockRegex.allMatches(message)) {
      blocks.add((
        start: match.start,
        end: match.end,
        raw: match.group(0) ?? '',
        isOpen: false,
      ));
      searchEnd = match.end;
    }

    final String tail = message.substring(searchEnd);
    final int openIndex = tail.indexOf(thinkingOpeningTag);
    if (openIndex >= 0) {
      blocks.add((
        start: searchEnd + openIndex,
        end: message.length,
        raw: tail.substring(openIndex),
        isOpen: true,
      ));
    }

    if (blocks.isEmpty) {
      return <ThinkingTagSegment>[];
    }
    if (blocks.length == 1) {
      final ({int start, int end, String raw, bool isOpen}) only = blocks.first;
      return <ThinkingTagSegment>[
        ThinkingTagSegment(
          blockIndex: 1,
          rawSegment: only.raw,
          isOpen: only.isOpen,
        ),
      ];
    }

    final List<List<({int start, int end, String raw, bool isOpen})>> groups =
        <List<({int start, int end, String raw, bool isOpen})>>[];
    List<({int start, int end, String raw, bool isOpen})> currentGroup =
        <({int start, int end, String raw, bool isOpen})>[blocks.first];

    for (int i = 1; i < blocks.length; i++) {
      final ({int start, int end, String raw, bool isOpen}) previous =
          blocks[i - 1];
      final ({int start, int end, String raw, bool isOpen}) next = blocks[i];
      final String between = message.substring(previous.end, next.start);
      if (between.trim().isEmpty) {
        currentGroup.add(next);
      } else {
        groups.add(currentGroup);
        currentGroup = <({int start, int end, String raw, bool isOpen})>[next];
      }
    }
    groups.add(currentGroup);

    final List<ThinkingTagSegment> merged = <ThinkingTagSegment>[];
    int blockIndex = 0;
    for (final List<({int start, int end, String raw, bool isOpen})> group
        in groups) {
      blockIndex++;
      final StringBuffer rawBuffer = StringBuffer();
      for (final ({int start, int end, String raw, bool isOpen}) block in group) {
        rawBuffer.write(block.raw);
      }
      merged.add(
        ThinkingTagSegment(
          blockIndex: blockIndex,
          rawSegment: rawBuffer.toString(),
          isOpen: group.last.isOpen,
        ),
      );
    }
    return merged;
  }

  /// Subject from the first block; thoughts from every block joined with blank lines.
  static ToolUseThinkingData? extractThinkingDataFromMergedThinkingRaw(
    String mergedRaw,
  ) {
    final List<ToolUseThinkingData> parts = <ToolUseThinkingData>[];
    for (final RegExpMatch match in _closedThinkingBlockRegex.allMatches(mergedRaw)) {
      final ToolUseThinkingData? data = extractThinkingDataFromSegment(
        match.group(0) ?? '',
      );
      if (data != null) {
        parts.add(data);
      }
    }

    final int lastClosedEnd = _closedThinkingBlockRegex
            .allMatches(mergedRaw)
            .lastOrNull
            ?.end ??
        0;
    final String tail = mergedRaw.substring(lastClosedEnd);
    if (tail.contains(thinkingOpeningTag)) {
      final ToolUseThinkingData? openData = extractThinkingDataFromSegment(tail);
      if (openData != null) {
        parts.add(openData);
      }
    }

    if (parts.isEmpty) {
      return null;
    }

    String subject = '';
    final List<String> thoughts = <String>[];
    for (final ToolUseThinkingData part in parts) {
      if (subject.isEmpty && part.subject.isNotEmpty) {
        subject = part.subject;
      }
      if (part.thought.isNotEmpty) {
        thoughts.add(part.thought);
      }
    }
    return ToolUseThinkingData(
      subject: subject,
      thought: thoughts.join('\n\n'),
    );
  }

  /// Extracts subject/thought from a single `<thinking>…</thinking>` segment.
  static ToolUseThinkingData? extractThinkingDataFromSegment(String segment) {
    if (!segment.contains(thinkingOpeningTag)) {
      return null;
    }
    final String subject = extractInlineThinkingSubject(segment);
    final String thought = extractInlineThinkingThought(segment);
    if (subject.isEmpty && thought.isEmpty) {
      return null;
    }
    return ToolUseThinkingData(subject: subject, thought: thought);
  }

  /// Extracts `<thinking>` data from the first block in [message] (legacy helper).
  static ToolUseThinkingData? extractThinkingDataFromLLMMessage(
    String message,
  ) {
    final List<ThinkingTagSegment> segments = enumerateThinkingTagSegments(message);
    if (segments.isEmpty) {
      return null;
    }
    return extractThinkingDataFromSegment(segments.first.rawSegment);
  }

  /// Inner `<thinking>` text from a full LLM [message] or one segment.
  static String thinkingBodyFromLLMMessage(String thinkingContent) {
    String body = thinkingContent.replaceAll('<line-break>', '\n').trim();
    final int openIndex = body.indexOf(thinkingOpeningTag);
    if (openIndex >= 0) {
      body = body.substring(openIndex + thinkingOpeningTag.length).trim();
      final int closeIndex = body.indexOf(thinkingClosingTag);
      if (closeIndex >= 0) {
        body = body.substring(0, closeIndex).trim();
      }
    }
    return body;
  }

  /// Inline `<thinking>` subject: first phrase, usually `**Title**` then two newlines.
  ///
  /// Accepts inner thinking text or a full LLM [message] (including an unclosed
  /// `<thinking>` tag). Returns `''` when no subject line is detected yet.
  static String extractInlineThinkingSubject(String thinkingContent) {
    try {
      final String body = thinkingBodyFromLLMMessage(thinkingContent);
      if (body.isEmpty) return '';
      final RegExpMatch? boldSubject = RegExp(
        r'^\*\*(.+?)\*\*',
      ).firstMatch(body);
      if (boldSubject != null) return (boldSubject.group(1) ?? '').trim();

      final List<String> lines = body.split('\n');
      if (lines.length >= 3 &&
          lines.first.trim().isNotEmpty &&
          lines[1].trim().isEmpty) {
        final String firstLine = lines.first.trim();
        final RegExpMatch? bold = RegExp(
          r'^\*\*(.+?)\*\*$',
        ).firstMatch(firstLine);
        if (bold != null) {
          return (bold.group(1) ?? '').trim();
        }
        return firstLine;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// Inline `<thinking>` thought: everything after the subject (rest of the block).
  ///
  /// Works while the tag is still open (SSE): once `**Title**` is present, all
  /// following text is treated as thought, even with only one newline so far.
  /// Returns `''` when only the subject line has arrived. If no subject is found
  /// yet, returns the whole thinking inner body.
  static String extractInlineThinkingThought(String thinkingContent) {
    try {
      final String body = thinkingBodyFromLLMMessage(thinkingContent);
      if (body.isEmpty) return '';

      final RegExpMatch? afterBoldSubject = RegExp(
        r'^\*\*(.+?)\*\*(?:\r?\n)*([\s\S]*)$',
      ).firstMatch(body);
      if (afterBoldSubject != null) {
        return (afterBoldSubject.group(2) ?? '').trim();
      }

      final List<String> lines = body.split('\n');
      if (lines.length >= 3 &&
          lines.first.trim().isNotEmpty &&
          lines[1].trim().isEmpty) {
        return lines.skip(2).join('\n').trim();
      }

      return body;
    } catch (e) {
      return '';
    }
  }

  /// Removes all `<thinking>…</thinking>` content from [message] for markdown display.
  ///
  /// - No `<thinking>` opening tag → returns [message] unchanged.
  /// - Open tag without `</thinking>` (SSE) → removes everything from `<thinking>` onward.
  /// - Closed tag(s) → removes each block including the tags and inner content.
  static String stripThinkingForMarkdown(String message) {
    if (!hasThinkingTag(message)) return message;

    String result = message.replaceAll(_closedThinkingBlockRegex, '');

    final int openIndex = result.indexOf(thinkingOpeningTag);
    if (openIndex >= 0) {
      result = result.substring(0, openIndex);
    }

    return result;
  }

  /// Strips custom Pupau tags and Markdown formatting for clipboard / plain-text export.
  /// Keeps human-visible text (e.g. option labels, link text, code content).
  static String plainTextForCopy(String message) {
    final String stripped = _stripCustomMarkupForCopy(message);
    final String plain = _markdownAstToPlainText(stripped);
    return plain
        .replaceAll(RegExp(r'\n\s*\n\s*\n+', multiLine: true), '\n\n')
        .trim();
  }

  static String _stripCustomMarkupForCopy(String baseMessage) {
    String message = baseMessage;
    message = message.replaceAllMapped(thinkingRegex, (_) => '');
    message = message.replaceAllMapped(optionsRegex, (m) {
      final block = m.group(0) ?? '';
      return _optionsBlockToPlainLines(block);
    });
    message = message.replaceAllMapped(
      RegExp(r'<reflection>([\s\S]*?)</reflection>', dotAll: true),
      (m) => (m.group(1)?.split('<evaluation').first ?? '').trim(),
    );
    message = message.replaceAllMapped(
      RegExp(r'<assistant[^>]*>([\s\S]*?)</assistant>'),
      (m) => (m.group(1) ?? '').trim(),
    );
    message = message.replaceAll(mapRegex, '');
    // Visual diagrams: omit source entirely from plain-text copy (like maps).
    message = message.replaceAll(mermaidRegex, '');
    message = message.replaceAllMapped(
      downloadRegex,
      (m) => (m.group(3) ?? '').trim(),
    );
    message = message.replaceAll(userNameTag, '');
    return message;
  }

  /// Visible lines from `<options>…</options>` (inner text of each `<option>`, no tags).
  static String _optionsBlockToPlainLines(String optionsBlock) {
    final String? content = RegExp(
      r'<options>([\s\S]*?)</options>',
      dotAll: true,
    ).firstMatch(optionsBlock)?.group(1);
    if (content == null) return '';
    final optionRegex = RegExp(
      r'<option\s+prompt="[^"]*">([\s\S]*?)</option>',
      dotAll: true,
    );
    final List<String> lines = [];
    for (final match in optionRegex.allMatches(content)) {
      final String line = (match.group(1) ?? '').trim();
      if (line.isNotEmpty) lines.add('- $line');
    }
    return lines.join('\n');
  }

  static String _markdownAstToPlainText(String markdown) {
    final md.Document doc = md.Document(
      extensionSet: md.ExtensionSet.gitHubFlavored,
    );
    final List<md.Node> nodes = doc.parseLines(markdown.split('\n'));
    return _markdownBlocksToPlainText(nodes);
  }

  /// Block-level plain text with list markers preserved (`- ` / `1. `). Using
  /// [Node.textContent] alone drops bullets because the AST stores them structurally.
  static String _markdownBlocksToPlainText(List<md.Node> nodes) {
    final List<String> parts = <String>[];
    for (final md.Node node in nodes) {
      final String t = _markdownBlockToPlainText(node).trimRight();
      if (t.isNotEmpty) parts.add(t);
    }
    return parts.join('\n\n');
  }

  static String _markdownBlockToPlainText(md.Node node) {
    if (node is md.Text) return node.text;
    if (node is md.Element) {
      switch (node.tag) {
        case 'ul':
          return _markdownUnorderedListToPlainText(node);
        case 'ol':
          return _markdownOrderedListToPlainText(node);
        default:
          return node.textContent;
      }
    }
    return node.textContent;
  }

  static String _markdownUnorderedListToPlainText(md.Element ul) {
    final List<String> lines = <String>[];
    for (final md.Node child in ul.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'li') {
        lines.add('- ${_markdownListItemToPlainText(child)}');
      }
    }
    return lines.join('\n');
  }

  static String _markdownOrderedListToPlainText(md.Element ol) {
    final List<String> lines = <String>[];
    int index = int.tryParse(ol.attributes['start'] ?? '') ?? 1;
    for (final md.Node child in ol.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'li') {
        lines.add('$index. ${_markdownListItemToPlainText(child)}');
        index++;
      }
    }
    return lines.join('\n');
  }

  static String _markdownListItemToPlainText(md.Element li) {
    final List<md.Node> children = li.children ?? const <md.Node>[];
    if (children.isEmpty) return '';

    final List<String> segments = <String>[];
    for (final md.Node child in children) {
      if (child is md.Element) {
        if (child.tag == 'ul') {
          segments.add(_markdownUnorderedListToPlainText(child));
        } else if (child.tag == 'ol') {
          segments.add(_markdownOrderedListToPlainText(child));
        } else {
          segments.add(child.textContent);
        }
      } else {
        segments.add(child.textContent);
      }
    }
    return segments.where((String s) => s.isNotEmpty).join('\n');
  }
}

/// One inline `<thinking>` block or merged consecutive run ([TagService.groupedConsecutiveThinkingTagSegments]).
class ThinkingTagSegment {
  const ThinkingTagSegment({
    required this.blockIndex,
    required this.rawSegment,
    this.isOpen = false,
  });

  /// 1-based index used for synthetic message ids (`{llmId}_thinking_1`, …).
  final int blockIndex;
  final String rawSegment;
  final bool isOpen;
}
