import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

class StringService {
  static String addLeadingZero(int number) =>
      number < 10 ? "0$number" : number.toString();

  static String removeTrailingZeros(String input, {int? maxDecimals}) {
    String result = input.replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
    if (maxDecimals != null) {
      int decimalIndex = result.indexOf('.');
      if (decimalIndex != -1) {
        String beforeDecimal = result.substring(0, decimalIndex);
        String afterDecimal = result.substring(decimalIndex + 1);
        if (afterDecimal.length > maxDecimals) {
          afterDecimal = afterDecimal.substring(0, maxDecimals);
        }
        result =
            beforeDecimal + (afterDecimal.isNotEmpty ? '.$afterDecimal' : '');
      }
    }
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }

  static String getRatingString(int rating) {
    switch (rating) {
      case 1:
        return Strings.conversationRate1.tr;
      case 2:
        return Strings.conversationRate2.tr;
      case 3:
        return Strings.conversationRate3.tr;
      case 4:
        return Strings.conversationRate4.tr;
      case 5:
        return Strings.conversationRate5.tr;
      default:
        return "";
    }
  }

  static String convertFancyQuotes(String string) => string
      .replaceAllMapped(RegExp(r'[\u2018\u2019\u201C\u201D\u2014]'), (match) {
        switch (match.group(0)) {
          case '\u2018': // left single quote (‘)
          case '\u2019': // right single quote (’)
            return "'";
          case '\u201C': // left double quote (“)
          case '\u201D': // right double quote (”)
            return '"';
          case '\u2014': // em dash (—)
            return '-';
          default:
            return match.group(0)!;
        }
      })
      .replaceAll(r'\n', '')
      .replaceAll(r'\\\"', "<backslash&quot>")
      .replaceAll(r'\', '')
      .replaceAll(r'<backslash&quot>', r'\"');

  static String prettifyJsonString(String? string) {
    String prettyString = string ?? "";
    try {
      prettyString =
          JsonEncoder.withIndent('  ').convert(json.decode(string ?? ""));
    } catch (e) {
      prettyString = string ?? "";
    }
    return prettyString;
  }

  static String fixMarkdownNewLines(String data) {
    final codeBlockPattern =
        RegExp(r'```.*?```', dotAll: true); // Matches code blocks
    final nonCodeBlocks = <String>[];
    final codeBlocks = <String>[];

    // Split data into segments of code blocks and non-code blocks
    final matches = codeBlockPattern.allMatches(data);
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before the code block as a non-code block
      if (match.start > lastMatchEnd) {
        nonCodeBlocks.add(data.substring(lastMatchEnd, match.start));
      }
      // Add the code block itself
      codeBlocks.add(data.substring(match.start, match.end));
      lastMatchEnd = match.end;
    }

    // Add any remaining non-code block text
    if (lastMatchEnd < data.length) {
      nonCodeBlocks.add(data.substring(lastMatchEnd));
    }

    // Process non-code blocks (using \u200B as a temporary hack to show new lines):
    final processedNonCodeBlocks = nonCodeBlocks.map((block) {
      return block
          .replaceAll(
              '\n\n\n\n', '\n\n\n\u200B\n') // First replace quadruple newlines
          .replaceAll('\n\n\n', '\n\n\u200B\n') // Then replace triple newlines
          .replaceAll('\n', '  \n'); // Then replace single newlines
    }).toList();

    // Combine processed non-code blocks and code blocks back together
    final buffer = StringBuffer();
    int codeIndex = 0, nonCodeIndex = 0;

    for (final _ in matches) {
      if (nonCodeIndex < processedNonCodeBlocks.length) {
        buffer.write(processedNonCodeBlocks[nonCodeIndex++]);
      }
      if (codeIndex < codeBlocks.length) {
        buffer.write(codeBlocks[codeIndex++]);
      }
    }

    // Add any remaining non-code block
    if (nonCodeIndex < processedNonCodeBlocks.length) {
      buffer.write(processedNonCodeBlocks[nonCodeIndex]);
    }

    return buffer.toString();
  }
}
