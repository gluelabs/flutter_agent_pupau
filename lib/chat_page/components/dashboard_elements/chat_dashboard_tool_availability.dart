import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_web_search_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';

bool webSearchToolQualifiesForDashboard(ToolUseMessage tool) {
  if (tool.type != ToolUseType.nativeToolsWebSearch) {
    return false;
  }
  final ToolUseWebSearchData? data = tool.webSearchData;
  if (data == null) {
    return false;
  }
  if (data.query.trim().isNotEmpty) {
    return true;
  }
  if (data.organicInfo.isNotEmpty) {
    return true;
  }
  if (data.images.isNotEmpty) {
    return true;
  }
  if (data.news.isNotEmpty) {
    return true;
  }
  return false;
}

bool remoteCallToolQualifiesForDashboard(ToolUseMessage tool) {
  if (tool.type != ToolUseType.remoteCall) {
    return false;
  }
  return tool.remoteCallData != null;
}

bool browserUseToolQualifiesForDashboard(ToolUseMessage tool) {
  if (tool.type != ToolUseType.nativeToolsBrowserUse) {
    return false;
  }
  if (tool.browserUseData == null) {
    return false;
  }
  if (tool.browserUseData!.isLoadingPlaceholder) {
    return false;
  }
  return true;
}

bool webReaderToolQualifiesForDashboard(ToolUseMessage tool) {
  if (tool.type != ToolUseType.nativeToolsWebReader) {
    return false;
  }
  final String url = tool.webReaderData?.url.trim() ?? "";
  return url.isNotEmpty;
}

/// Web search, web reader, remote API calls, and browser automation rows in the dashboard.
bool webDashboardSectionToolQualifies(ToolUseMessage tool) {
  return webSearchToolQualifiesForDashboard(tool) ||
      remoteCallToolQualifiesForDashboard(tool) ||
      browserUseToolQualifiesForDashboard(tool) ||
      webReaderToolQualifiesForDashboard(tool);
}

bool nativeDatabaseToolQualifiesForDashboard(ToolUseMessage tool) {
  if (tool.type != ToolUseType.nativeToolsNativeDatabase) {
    return false;
  }
  return tool.nativeDatabaseData != null || tool.spreadsheetData != null;
}

bool mailToolQualifiesForDashboard(ToolUseMessage tool) {
  return tool.type == ToolUseType.nativeToolsMail && tool.mailData != null;
}

bool smtpToolQualifiesForDashboard(ToolUseMessage tool) {
  return tool.type == ToolUseType.nativeToolsSMTP && tool.smtpData != null;
}

bool pupauMessageQualifiesForDashboardWebSection(PupauMessage message) {
  if (message.sourceType != SourceType.toolUse) {
    return false;
  }
  final ToolUseMessage? tool = message.toolUseMessage;
  if (tool == null) {
    return false;
  }
  return webDashboardSectionToolQualifies(tool);
}

bool pupauMessageQualifiesForDashboardNativeDatabase(PupauMessage message) {
  if (message.sourceType != SourceType.toolUse) {
    return false;
  }
  final ToolUseMessage? tool = message.toolUseMessage;
  if (tool == null) {
    return false;
  }
  return nativeDatabaseToolQualifiesForDashboard(tool);
}

bool pupauMessageQualifiesForDashboardMailTool(PupauMessage message) {
  if (message.sourceType != SourceType.toolUse) {
    return false;
  }
  final ToolUseMessage? tool = message.toolUseMessage;
  if (tool == null) {
    return false;
  }
  return mailToolQualifiesForDashboard(tool);
}

bool pupauMessageQualifiesForDashboardSmtpTool(PupauMessage message) {
  if (message.sourceType != SourceType.toolUse) {
    return false;
  }
  final ToolUseMessage? tool = message.toolUseMessage;
  if (tool == null) {
    return false;
  }
  return smtpToolQualifiesForDashboard(tool);
}

bool pupauMessageQualifiesForDashboardDocumentTool(PupauMessage message) {
  if (message.sourceType != SourceType.toolUse) {
    return false;
  }
  final ToolUseMessage? tool = message.toolUseMessage;
  if (tool == null) {
    return false;
  }
  return tool.type == ToolUseType.nativeToolsDocument &&
      tool.documentData != null;
}
