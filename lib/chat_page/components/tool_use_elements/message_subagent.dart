import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_subagent_data.dart';
import 'package:flutter_agent_pupau/utils/pupau_chat_utils.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

/// UI for native SUBAGENT / `subagent_*` tools (e.g. `subagent_spawn`).
class MessageSubagent extends StatelessWidget {
  const MessageSubagent({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseSubagentData? data = toolUseMessage.subagentData;
    if (data == null) {
      return const SizedBox.shrink();
    }
    final SubagentSpawnInfo? first = data.firstInfo;
    final TextStyle baseStyle = TextStyle(
      fontSize: 14,
      height: 1.35,
      color: isAnonymous ? Colors.white.withValues(alpha: 0.92) : null,
    );

    if (first == null) {
      if (data.message.trim().isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SelectableText(data.message, style: baseStyle),
        );
      }
      return const SizedBox.shrink();
    }

    switch (first.status) {
      case SubagentSpawnStatus.accepted:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Strings.subagentAsyncPending.tr, style: baseStyle),
              if (first.note != null && first.note!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SelectableText(first.note!, style: baseStyle),
                ),
            ],
          ),
        );
      case SubagentSpawnStatus.completed:
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (first.childConversationHashId != null &&
                  first.childConversationHashId!.trim().isNotEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 12),
                    child: CustomButton(
                      text: Strings.subagentOpenChildConversation.tr,
                      isPrimary: false,
                      hasBorders: true,
                      onPressed: () => PupauChatUtils.loadConversation(
                        first.childConversationHashId!.trim(),
                      ),
                    ),
                  ),
                ),
              if (data.message.trim().isNotEmpty)
                SelectableText(data.message, style: baseStyle),
            ],
          ),
        );
      case SubagentSpawnStatus.error:
        final String err = first.error?.trim().isNotEmpty == true
            ? first.error!.trim()
            : data.errors.join('\n');
        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: SelectableText(
            err.isNotEmpty ? err : Strings.subagentErrorGeneric.tr,
            style: baseStyle.copyWith(
              color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
            ),
          ),
        );
      case SubagentSpawnStatus.unknown:
        if (data.message.trim().isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SelectableText(data.message, style: baseStyle),
          );
        }
        return const SizedBox.shrink();
    }
  }
}
