import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class ToolUseToDoListData {
  List<ToDoTask> tasks;
  String? action;
  int? actionParameter;
  String? toolId;

  ToolUseToDoListData({
    required this.tasks,
    this.action,
    this.actionParameter,
    this.toolId,
  });

  factory ToolUseToDoListData.fromJson(Map<String, dynamic> json, Map<String, dynamic>? jsonTypeDetails) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    if (firstInfo.isEmpty) return ToolUseToDoListData(tasks: []);
    List todoList = firstInfo["todoList"] ?? [];
    String toolId= jsonTypeDetails?["toolId"] ?? "";
    String? action = jsonTypeDetails?["toolArgs"]?["action"];
    int? actionParameter = jsonTypeDetails?["toolArgs"]?["actionParameter"] != null ? getInt(jsonTypeDetails?["toolArgs"]?["actionParameter"]) : null;
    return ToolUseToDoListData(
        tasks: todoList.map((e) => ToDoTask.fromJson(e)).toList(),
        action: action,
        actionParameter: actionParameter,
        toolId: toolId);
  }

  String? getActionName() =>
      action == null ? "" : action?.replaceAll("_", " ").capitalize;
}

class ToDoTask {
  String task;
  bool isDone;
  String? itemId;

  ToDoTask({
    required this.task,
    required this.isDone,
    required this.itemId,
  });

  factory ToDoTask.fromJson(Map<String, dynamic> json) => ToDoTask(
        task: json["task"] ?? "",
        isDone: json["done"] ?? false,
        itemId: json["todoListItemId"]?.toString(),
      );
}