import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';

/// Sealed discriminated union of items that can be opened in the dashboard canvas.
sealed class DashboardCanvasItem {
  String get canvasId;
  String get canvasTitle;
}

final class ToolMessageCanvasItem extends DashboardCanvasItem {
  ToolMessageCanvasItem(this.toolUseMessage);

  final ToolUseMessage toolUseMessage;

  @override
  String get canvasId => toolUseMessage.id;

  @override
  String get canvasTitle => toolUseMessage.getName();
}

final class DocumentCanvasItem extends DashboardCanvasItem {
  DocumentCanvasItem(this.document);

  final DocumentData document;

  @override
  String get canvasId => document.id;

  @override
  String get canvasTitle {
    final Attachment? attachment = document.relatedAttachment;
    if (attachment != null) {
      return '${attachment.fileName}.${attachment.extension}';
    }
    return document.fileName;
  }
}

final class AttachmentCanvasItem extends DashboardCanvasItem {
  AttachmentCanvasItem(this.attachment);

  final Attachment attachment;

  @override
  String get canvasId => attachment.id;

  @override
  String get canvasTitle =>
      '${attachment.fileName}.${attachment.extension}';
}
