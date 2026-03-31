import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/task_create_content.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_task_data.dart';

/// Mobile-friendly presentation for the task tool (create_task, task_list, etc.).
/// For task_create: shows capabilities pills, task name, type/target chips, cron, timezone, and error.
class MessageTaskTool extends StatelessWidget {
  const MessageTaskTool({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseTaskData? data = toolUseMessage?.taskToolData;
    if (data == null) return const SizedBox.shrink();
    return TaskCreateContent(data: data, isAnonymous: isAnonymous);
  }
}
