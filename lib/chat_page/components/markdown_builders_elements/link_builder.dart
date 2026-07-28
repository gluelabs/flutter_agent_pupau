import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class LinkBuilder extends MarkdownElementBuilder {
  LinkBuilder({required this.isFromAssistant, required this.isAnonymous});

  final bool isFromAssistant;
  final bool isAnonymous;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    // Inherit the surrounding paragraph's font size/height so this run
    // flows like the rest of the text it sits in.
    final TextStyle linkStyle =
        (parentStyle ?? preferredStyle ?? const TextStyle()).copyWith(
          fontWeight: isFromAssistant ? FontWeight.w500 : FontWeight.w800,
          color: isFromAssistant
              ? isAnonymous
                    ? Colors.white
                    : MyStyles.pupauTheme(!Get.isDarkMode).primary
              : isAnonymous
              ? Colors.black87
              : MyStyles.getTextTheme(
                      isLightTheme: true,
                    ).bodyMedium?.color ??
                    Colors.black,
        );
    return RichText(
      text: TextSpan(
        text: element.textContent,
        style: linkStyle,
        recognizer: TapGestureRecognizer()
          ..onTap = () => DeviceService.openLink(
            element.attributes['href'] ?? element.textContent,
          ),
      ),
    );
  }
}
