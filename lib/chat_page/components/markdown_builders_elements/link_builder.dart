import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class LinkBuilder extends MarkdownElementBuilder {
  LinkBuilder({
    required this.isFromAssistant,
    required this.isAnonymous,
  });

  final bool isFromAssistant;
  final bool isAnonymous;

  @override
  Widget? visitElementAfterWithContext(BuildContext context, md.Element element,
      TextStyle? preferredStyle, TextStyle? parentStyle) {
    return RichText(
      text: TextSpan(
        text: "",
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              child: InkWell(
                onTap: () => {
                  DeviceService.openLink(
                      element.attributes['href'] ?? element.textContent)
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
                  child: Text(element.textContent,
                      style: TextStyle(
                          fontWeight: isFromAssistant
                              ? FontWeight.w500
                              : FontWeight.w800,
                          color: isFromAssistant
                              ? isAnonymous
                                  ? Colors.white
                                  : MyStyles.pupauTheme(!Get.isDarkMode).blue
                              : isAnonymous
                                  ? Colors.black87
                                  : MyStyles.getTextTheme(
                                              isLightTheme: Get.isDarkMode)
                                          .bodyMedium
                                          ?.color ??
                                      Colors.white)),
                ),
              ),
            ),
          ),
        ],
        recognizer: TapGestureRecognizer()
          ..onTap = () => DeviceService.openLink(
              element.attributes['href'] ?? element.textContent),
      ),
    );
  }
}
