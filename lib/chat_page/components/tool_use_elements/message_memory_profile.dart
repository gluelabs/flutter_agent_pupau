import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_memory_profile_data.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class MessageMemoryProfile extends StatelessWidget {
  const MessageMemoryProfile({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseMemoryProfileData? data = toolUseMessage?.memoryProfileData;
    if (data == null) return const SizedBox.shrink();

    final bool isDark = Get.isDarkMode || isAnonymous;
    final TextStyle normalStyle = StyleService.toolNormalTextStyle(isDark);

    final String primaryText = _primaryText(data);
    final String primaryTextLowerCase = primaryText.trim().toLowerCase();
    final String primaryTextWithoutError = primaryTextLowerCase
        .replaceAll("error:", "")
        .trim();
    final String errors = data.errors
        .join('\n')
        .trim()
        .toLowerCase(); //Used to check if the primary text is the same as the errors
    final bool primaryTextIsSameAsErrors =
        primaryTextLowerCase == errors || primaryTextWithoutError == errors;
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (primaryText.trim().isNotEmpty && !primaryTextIsSameAsErrors) ...[
            Text(primaryText, style: normalStyle),
          ],
          if (data.errors.isNotEmpty) ...[
            if (primaryText.trim().isNotEmpty && !primaryTextIsSameAsErrors)
              const SizedBox(height: 8),
            for (final String e in data.errors)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${Strings.error.tr}: ${e.trim()}',
                  style: normalStyle.copyWith(
                    color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _primaryText(ToolUseMemoryProfileData data) {
    final String msg = data.message.trim();
    if (msg.isNotEmpty) return msg;
    final String memory = data.memory.trim();
    if (memory.isNotEmpty) return memory;
    final String query = data.query.trim();
    return query;
  }
}
