import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class MessageCodeInterpreter extends StatelessWidget {
  const MessageCodeInterpreter({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final data = toolUseMessage?.codeInterpreterData;
    final bool isTablet = DeviceService.isTablet;
    final TextStyle labelStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode || isAnonymous ? Colors.white : Colors.black87,
    );
    final TextStyle secondaryTextStyle = TextStyle(
      fontSize: isTablet ? 14 : 13,
      color: Get.isDarkMode || isAnonymous ? Colors.white70 : Colors.black87,
    );

    if (data == null) {
      final String fallback =
          toolUseMessage?.nativeToolData?['message']?.toString() ?? '';
      return fallback.trim().isEmpty
          ? const SizedBox.shrink()
          : CustomSelectableText(text: fallback, isAnonymous: isAnonymous);
    }

    final TextStyle outputStyle = TextStyle(
      fontSize: isTablet ? 16 : 14,
      color: isAnonymous
          ? AnonymousThemeColors.assistantText
          : MyStyles.getTextTheme(
              isLightTheme: !Get.isDarkMode,
            ).bodyMedium?.color,
    );

    final bool hasOutput = data.output.trim().isNotEmpty;
    final bool hasErrors = data.errors.isNotEmpty;
    final Color statusColor = data.success
        ? MyStyles.pupauTheme(!Get.isDarkMode).green
        : MyStyles.pupauTheme(!Get.isDarkMode).redAlarm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.success ? Strings.success.tr : Strings.failed.tr,
          style: labelStyle.copyWith(color: statusColor),
        ),

        if (data.language.trim().isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${Strings.language.tr}: ', style: labelStyle),
              Text(data.language.trim(), style: secondaryTextStyle),
            ],
          ),
        ],
        if (data.executionTimeMs > 0) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${Strings.time.tr}: ', style: labelStyle),
              Text('${data.executionTimeMs}ms', style: secondaryTextStyle),
            ],
          ),
        ],
        const SizedBox(height: 4),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            initiallyExpanded: true,
            title: Text(Strings.code.tr, style: labelStyle),
            children: [
              if (data.code.trim().isEmpty)
                Text(
                  Strings.noCodeProvided.tr,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: Get.isDarkMode || isAnonymous
                        ? Colors.white60
                        : Colors.black54,
                  ),
                )
              else
                CustomSelectableText(text: data.code, isAnonymous: isAnonymous),
              const SizedBox(height: 10),
            ],
          ),
        ),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            initiallyExpanded: true,
            title: Text(Strings.result.tr, style: labelStyle),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!hasOutput && !hasErrors)
                    Text(Strings.noOutput.tr, style: outputStyle),
                  if (hasOutput) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CustomSelectableText(
                        text: data.output,
                        isAnonymous: isAnonymous,
                      ),
                    ),
                  ],
                  if (hasErrors) ...[
                    const SizedBox(height: 6),
                    Text(
                      Strings.errors.tr,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...data.errors.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: CustomSelectableText(
                          text: e,
                          isAnonymous: isAnonymous,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
