import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/prompt_reflection_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

const String _leadingIconMarker = '\uE000';

class ReflectionTagContainer extends GetView<PupauChatController> {
  const ReflectionTagContainer({super.key, required this.reflection});

  final PromptReflection reflection;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 14),
      child: Obx(() {
        final bool isAnonymous = controller.isAnonymous;
        final bool isLastMessage =
            // ignore: invalid_use_of_protected_member
            controller.messages.value.first.id == reflection.messageId;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isAnonymous
                ? AnonymousThemeColors.background
                : MyStyles.pupauTheme(
                    !Get.isDarkMode,
                  ).grey.withValues(alpha: Get.isDarkMode ? 1 : 0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarkdownBody(
                data: '$_leadingIconMarker ${reflection.text}',
                selectable: true,
                inlineSyntaxes: [_LeadingIconSyntax()],
                builders: {
                  'leading-icon': _LeadingIconBuilder(
                    icon: Symbols.neurology,
                    size: isTablet ? 26 : 24,
                    color: isAnonymous
                        ? AnonymousThemeColors.assistantText
                        : MyStyles.pupauTheme(!Get.isDarkMode).primary,
                  ),
                },
                styleSheet:
                    MarkdownStyleSheet.fromTheme(
                      ThemeData(
                        brightness: Get.isDarkMode
                            ? Brightness.dark
                            : Brightness.light,
                        textTheme: TextTheme(
                          bodyMedium: TextStyle(
                            fontSize: isTablet ? 17 : 15,
                            color: isAnonymous
                                ? AnonymousThemeColors.assistantText
                                : null,
                          ),
                        ),
                      ),
                    ).copyWith(
                      blockquoteDecoration: BoxDecoration(
                        color: MyStyles.pupauTheme(
                          !Get.isDarkMode,
                        ).primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquotePadding: const EdgeInsets.all(12),
                    ),
              ),
              if ((!reflection.isPositive) && isLastMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 2),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.sendMessage(
                          controller.messages[1].answer,
                          false,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Text(
                            Strings.improveResponse.tr,
                            style: TextStyle(
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w500,
                              color: isAnonymous
                                  ? AnonymousThemeColors.assistantText
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _LeadingIconSyntax extends md.InlineSyntax {
  _LeadingIconSyntax() : super(_leadingIconMarker);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.withTag('leading-icon'));
    return true;
  }
}

class _LeadingIconBuilder extends MarkdownElementBuilder {
  _LeadingIconBuilder({
    required this.icon,
    required this.size,
    required this.color,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    return Text.rich(
      WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}
