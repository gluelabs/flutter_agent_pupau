import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class LoadingMessage {
  String message;
  LoadingType? loadingType;
  ToolUseType? toolUseType;

  /// Optional list of active tool loadings (when [loadingType] == [LoadingType.toolUse]).
  /// When empty, [message] / [toolUseType] represent a single tool loading.
  final List<ToolLoadingEntry> tools;

  LoadingMessage({
    required this.message,
    this.loadingType,
    this.toolUseType,
    this.tools = const [],
  });
}

/// Represents a single tool loading entry (pending or running).
class ToolLoadingEntry {
  final String name;
  final String key;
  final ToolUseType? type;

  const ToolLoadingEntry({required this.name, required this.key, this.type});
}

enum LoadingType { dots, text, browserUse, webSearch, tag, toolUse }
