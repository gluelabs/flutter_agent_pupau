import 'package:flutter_agent_pupau/services/tool_use_service.dart';

class LoadingMessage {
  String message;
  LoadingType? loadingType;
  ToolUseType? toolUseType;

  LoadingMessage({required this.message, this.loadingType, this.toolUseType});
}

enum LoadingType { dots, text, browserUse, webSearch, tag, toolUse }