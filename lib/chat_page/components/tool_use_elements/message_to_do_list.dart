import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_to_do_list_data.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/todo_item.dart';

class MessageToDoList extends StatelessWidget {
  const MessageToDoList({
    super.key,
    required this.toolUseMessage,
    this.isAnonymous = false,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    List<ToDoTask> tasks = toolUseMessage?.toDoListData?.tasks ?? [];
    return Column(
      children: [
        ...tasks.map((ToDoTask task) => ToDoItem(
              task: task,
              isAnonymous: isAnonymous,
            )),
      ],
    );
  }
}
