import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';

/// Content for a "SKILL" native-tool call that isn't an actual load/unload
/// event (e.g. `skill_list`, or a `skill_load` that failed) — same single
/// text, single-expandable shape as [MessageThinking], not the generic
/// multi-row info-list view.
class MessageSkillTool extends StatelessWidget {
  const MessageSkillTool({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final String message = toolUseMessage?.skillToolMessage ?? '';
    return SizedBox(
      width: double.infinity,
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomSelectableText(text: message, isAnonymous: isAnonymous),
      ),
    );
  }
}
