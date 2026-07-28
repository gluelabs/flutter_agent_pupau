import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_attachment_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_database_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_document_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_mail_tool_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_smtp_tool_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_terminal_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_web_section_tile.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_expandable_section.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_bubble.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_document_data.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

/// Full dashboard tool list. Reads all state from [ChatDashboardController]
/// and [PupauAttachmentsController] directly — no parameters required.
class DashboardListView extends GetView<ChatDashboardController> {
  const DashboardListView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = Get.find<PupauChatController>().isAnonymous;

    return Obx(() {
      final bool hasTodo = controller.latestTodoListMessage.value != null;
      final ToolUseMessage? toolUseMessage =
          controller.latestTodoListMessage.value?.toolUseMessage;

      final List<PupauMessage> documentMessages =
          controller.latestDocumentMessages;
      final List<DocumentData> allDashboardDocuments =
          ToolUseService.resolveDashboardDocuments(documentMessages);

      // Attachments have priority: exclude documents that duplicate an entry
      // already present in the user's attachment list.
      final List<Attachment> allAttachments =
          Get.isRegistered<PupauAttachmentsController>()
          ? Get.find<PupauAttachmentsController>().attachments
          : <Attachment>[];
      final Set<String> attachmentIds = allAttachments
          .map((Attachment a) => a.id)
          .toSet();
      final List<DocumentData> dashboardDocuments = allDashboardDocuments
          .where(
            (DocumentData doc) =>
                doc.relatedAttachment == null ||
                !attachmentIds.contains(doc.relatedAttachment!.id),
          )
          .toList();

      final int documentToolRowsCount = dashboardDocuments.length;

      final List<PupauMessage> mailMessages = controller.latestMailToolMessages;
      final List<PupauMessage> smtpMessages = controller.latestSmtpToolMessages;
      final int mailCount = mailMessages.length;
      final int smtpCount = smtpMessages.length;

      final int attachmentCount = allAttachments.length;
      final int documentsSectionCount =
          documentToolRowsCount + mailCount + smtpCount + attachmentCount;

      final List<PupauMessage> webSectionMessages =
          controller.latestWebSectionMessages;
      final int webSectionCount = webSectionMessages.length;

      final List<PupauMessage> nativeDatabaseMessages =
          controller.latestNativeDatabaseMessages;
      final int nativeDatabaseCount = nativeDatabaseMessages.length;

      final List<PupauMessage> terminalMessages =
          controller.latestTerminalMessages;
      final int terminalCount = terminalMessages.length;

      final bool isEmpty =
          !hasTodo &&
          documentsSectionCount == 0 &&
          webSectionCount == 0 &&
          nativeDatabaseCount == 0 &&
          terminalCount == 0;

      if (isEmpty) return const SizedBox.shrink();

      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (hasTodo && toolUseMessage != null)
              DashboardExpandableSection(
                label: "To-do",
                childCount: 1,
                childBuilder: (int index) => ToolUseBubble(
                  message: toolUseMessage,
                  disableCollapseAndToggle: true,
                  showContentOnly: true,
                  hideBorder: true,
                ),
              ),
            if (documentsSectionCount > 0)
              DashboardExpandableSection(
                label: Strings.documents.tr,
                childCount: documentsSectionCount,
                childBuilder: (int index) {
                  if (index < documentToolRowsCount) {
                    return ChatDashboardDocumentTile(
                      document: dashboardDocuments[index],
                    );
                  }
                  int offset = index - documentToolRowsCount;
                  if (offset < mailCount) {
                    final ToolUseMessage? tool =
                        mailMessages[offset].toolUseMessage;
                    if (tool == null) return const SizedBox.shrink();
                    return ChatDashboardMailToolTile(
                      toolUseMessage: tool,
                      isAnonymous: isAnonymous,
                    );
                  }
                  offset -= mailCount;
                  if (offset < smtpCount) {
                    final ToolUseMessage? tool =
                        smtpMessages[offset].toolUseMessage;
                    if (tool == null) return const SizedBox.shrink();
                    return ChatDashboardSmtpToolTile(toolUseMessage: tool);
                  }
                  offset -= smtpCount;
                  if (offset >= allAttachments.length) {
                    return const SizedBox.shrink();
                  }
                  return ChatDashboardAttachmentTile(
                    attachment: allAttachments[offset],
                  );
                },
              ),
            if (webSectionCount > 0)
              DashboardExpandableSection(
                label: Strings.webSearch.tr,
                childCount: webSectionCount,
                childBuilder: (int index) {
                  final ToolUseMessage? tool =
                      webSectionMessages[index].toolUseMessage;
                  if (tool == null) return const SizedBox.shrink();
                  return ChatDashboardWebSectionTile(
                    toolUseMessage: tool,
                    isAnonymous: isAnonymous,
                  );
                },
              ),
            if (nativeDatabaseCount > 0)
              DashboardExpandableSection(
                label: Strings.databases.tr,
                childCount: nativeDatabaseCount,
                childBuilder: (int index) {
                  final ToolUseMessage? tool =
                      nativeDatabaseMessages[index].toolUseMessage;
                  if (tool == null) return const SizedBox.shrink();
                  return ChatDashboardDatabaseTile(
                    toolUseMessage: tool,
                    isAnonymous: isAnonymous,
                  );
                },
              ),
            if (terminalCount > 0)
              DashboardExpandableSection(
                label: Strings.terminal.tr,
                childCount: terminalCount,
                childBuilder: (int index) {
                  final ToolUseMessage? tool =
                      terminalMessages[index].toolUseMessage;
                  if (tool == null) return const SizedBox.shrink();
                  return ChatDashboardTerminalTile(
                    toolUseMessage: tool,
                    isAnonymous: isAnonymous,
                  );
                },
              ),
          ],
        ),
      );
    });
  }
}
