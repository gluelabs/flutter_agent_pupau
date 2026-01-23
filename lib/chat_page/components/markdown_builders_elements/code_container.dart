import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:highlight/highlight.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({
    super.key,
    required this.element,
  });

  final md.Element element;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    final String text = element.textContent.trim();
    final bool isSingleLine = !text.contains('\n');
    CodeController codeController = CodeController(
      text: text,
      language: Mode(ref: element.attributes['language'] ?? 'dart'),
      readOnly: true,
    );
    final Widget copyButton = IconButton(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: text));
          showFeedbackSnackbar(Strings.copiedClipboard.tr, Symbols.content_copy,
              isInfo: true);
        },
        tooltip: Strings.copy.tr,
        icon: Icon(
          Symbols.content_copy,
          size: isTablet ? 26 : 24,
          color: Colors.white.withAlpha(220),
        ));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
          width: DeviceService.width,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: MyStyles.pupauTheme(!Get.isDarkMode).codeBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: isSingleLine
                ? [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Theme(
                            data: ThemeData(),
                            child: CodeField(
                                controller: codeController,
                                gutterStyle: GutterStyle.none,
                                minLines: 1,
                                maxLines: 1,
                                background: Colors.transparent,
                                textStyle: TextStyle(
                                    fontSize: isTablet ? 17 : 15,
                                    color: Colors.white.withAlpha(220))),
                          ),
                        ),
                        Transform.translate(
                            offset: Offset(12, 0), child: copyButton),
                      ],
                    )
                  ]
                : [
                    Transform.translate(
                      offset: Offset(12, 0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: copyButton,
                      ),
                    ),
                    Theme(
                      data: ThemeData(),
                      child: CodeField(
                          controller: codeController,
                          gutterStyle: GutterStyle.none,
                          background: Colors.transparent,
                          textStyle: TextStyle(
                              fontSize: isTablet ? 17 : 15,
                              color: Colors.white.withAlpha(220))),
                    ),
                  ],
          )),
    );
  }
}
