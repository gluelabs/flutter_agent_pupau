import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:get/get.dart';
import 'package:highlight/highlight.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Dark, rounded, monospace code box with a copy button — the canonical
/// "code block" look originally built for fenced markdown code (see
/// `CodeContainer`, which now just wraps this) and reused wherever other
/// content (e.g. tool command/output) should read as code/terminal text.
class CodeBlock extends StatelessWidget {
  const CodeBlock({super.key, required this.text, this.language});

  final String text;
  final String? language;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final String trimmed = text.trim();
    final bool isSingleLine = !trimmed.contains('\n');
    final CodeController codeController = CodeController(
      text: trimmed,
      language: language != null ? Mode(ref: language!) : null,
      readOnly: true,
    );
    final Widget copyButton = IconButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: trimmed));
        showFeedbackSnackbar(
          Strings.copiedClipboard.tr,
          Symbols.content_copy,
          isInfo: true,
        );
      },
      tooltip: Strings.copy.tr,
      icon: Icon(
        Symbols.content_copy,
        size: isTablet ? 26 : 24,
        color: Colors.white.withAlpha(220),
      ),
    );
    return Container(
      width: DeviceService.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(12, 0),
                      child: copyButton,
                    ),
                  ],
                ),
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
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                ),
              ],
      ),
    );
  }
}
