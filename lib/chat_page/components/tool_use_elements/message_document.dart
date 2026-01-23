import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/document_tool_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/document_tool_download.dart';

class MessageDocument extends GetView<ChatController> {
  const MessageDocument({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    List<DocumentData> documents =
        toolUseMessage?.documentData?.documents ?? [];
    ToolDocumentAction action = ToolUseService.getToolDocumentActionEnum(
        toolUseMessage?.documentData?.action ?? "");
    String message = toolUseMessage?.nativeToolData?["message"] ?? "";
    bool hasMessage = message.trim() != "";
    bool hasError = message.toLowerCase().contains("error");
    bool hasDocuments = documents.isNotEmpty;
    bool isUnknownAction = action == ToolDocumentAction.unknown;
    List<DocumentData> documentsExported =
        ToolUseService.getToolUseDocumentsWithExportUrl(documents);
    documents = ToolUseService.setToolUseDocumentsRelatedAttachment(documents);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasMessage || isUnknownAction || hasError)
          Text(
            hasError
                ? Strings.documentOperationFailed.tr
                : isUnknownAction
                    ? message
                    : ToolUseService.getToolDocumentActionDescription(action),
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
            ),
          ),
        if (hasMessage && hasDocuments) const SizedBox(height: 12),
        if (hasDocuments)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (documentsExported.isEmpty)
                Text(
                  Strings.documentsManaged.tr,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                ...documentsExported.map(
                  (DocumentData document) => DocumentToolDownload(
                      isAnonymous: isAnonymous, document: document),
                ),
              const SizedBox(height: 6),
              if (documentsExported.isEmpty)
                ...documents.map(
                  (DocumentData document) =>
                      DocumentToolCard(document: document),
                ),
            ],
          )
      ],
    );
  }
}
