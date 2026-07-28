import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/chat_dashboard_tool_availability.dart';
import 'package:flutter_agent_pupau/chat_page/components/dashboard_elements/dashboard_canvas_item.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:get/get.dart';

class ChatDashboardController extends GetxController {
  late final PupauChatController _chatController;
  Worker? _attachmentsListWorker;

  final Rxn<PupauMessage> latestTodoListMessage = Rxn<PupauMessage>();
  final RxList<PupauMessage> latestDocumentMessages = <PupauMessage>[].obs;
  final RxList<PupauMessage> latestWebSectionMessages = <PupauMessage>[].obs;
  final RxList<PupauMessage> latestNativeDatabaseMessages =
      <PupauMessage>[].obs;
  final RxList<PupauMessage> latestTerminalMessages = <PupauMessage>[].obs;
  final RxList<PupauMessage> latestMailToolMessages = <PupauMessage>[].obs;
  final RxList<PupauMessage> latestSmtpToolMessages = <PupauMessage>[].obs;

  final Rxn<DashboardCanvasItem> selectedCanvasItem =
      Rxn<DashboardCanvasItem>();

  void selectCanvasItem(DashboardCanvasItem item) {
    // For attachment items, trigger the content load synchronously so that
    // attachmentIdsLoadingNoteModal is populated before the canvas widget builds.
    if (item is AttachmentCanvasItem &&
        Get.isRegistered<PupauAttachmentsController>()) {
      Get.find<PupauAttachmentsController>().loadAttachmentForCanvas(
        item.attachment,
      );
    }
    selectedCanvasItem.value = item;
    update();
  }

  void clearCanvasItem() {
    selectedCanvasItem.value = null;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _chatController = Get.find<PupauChatController>();
    _rebuild();
    ever<List<PupauMessage>>(_chatController.messages, (_) => _rebuild());
    if (Get.isRegistered<PupauAttachmentsController>()) {
      _attachmentsListWorker = ever<List<Attachment>>(
        Get.find<PupauAttachmentsController>().attachments,
        (_) => _rebuild(),
      );
    }
  }

  @override
  void onClose() {
    _attachmentsListWorker?.dispose();
    _attachmentsListWorker = null;
    super.onClose();
  }

  void _rebuild() {
    final Map<String, PupauMessage> latestDocumentByToolUseId =
        <String, PupauMessage>{};
    final Map<String, PupauMessage> latestWebSectionByToolUseId =
        <String, PupauMessage>{};
    final Map<String, PupauMessage> latestNativeDatabaseByToolUseId =
        <String, PupauMessage>{};
    final Map<String, PupauMessage> latestTerminalByToolUseId =
        <String, PupauMessage>{};
    final Map<String, PupauMessage> latestMailByToolUseId =
        <String, PupauMessage>{};
    final Map<String, PupauMessage> latestSmtpByToolUseId =
        <String, PupauMessage>{};
    PupauMessage? latestTodo;

    for (final PupauMessage message in _chatController.messages) {
      if (message.sourceType != SourceType.toolUse) continue;
      final ToolUseMessage? toolUseMessage = message.toolUseMessage;
      if (toolUseMessage == null) continue;

      final String toolUseId = toolUseMessage.id;
      if (toolUseId.trim().isEmpty) continue;

      if (toolUseMessage.type == ToolUseType.nativeToolsToDoList &&
          toolUseMessage.toDoListData != null) {
        if (latestTodo == null ||
            message.createdAt.isAfter(latestTodo.createdAt)) {
          latestTodo = message;
        }
      }

      if (toolUseMessage.type == ToolUseType.nativeToolsDocument &&
          toolUseMessage.documentData != null) {
        final PupauMessage? current = latestDocumentByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestDocumentByToolUseId[toolUseId] = message;
        }
      }

      if (webDashboardSectionToolQualifies(toolUseMessage)) {
        final PupauMessage? current = latestWebSectionByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestWebSectionByToolUseId[toolUseId] = message;
        }
      }

      if (nativeDatabaseToolQualifiesForDashboard(toolUseMessage)) {
        final PupauMessage? current =
            latestNativeDatabaseByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestNativeDatabaseByToolUseId[toolUseId] = message;
        }
      }

      if (terminalToolQualifiesForDashboard(toolUseMessage)) {
        final PupauMessage? current = latestTerminalByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestTerminalByToolUseId[toolUseId] = message;
        }
      }

      if (mailToolQualifiesForDashboard(toolUseMessage)) {
        final PupauMessage? current = latestMailByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestMailByToolUseId[toolUseId] = message;
        }
      }

      if (smtpToolQualifiesForDashboard(toolUseMessage)) {
        final PupauMessage? current = latestSmtpByToolUseId[toolUseId];
        if (current == null || message.createdAt.isAfter(current.createdAt)) {
          latestSmtpByToolUseId[toolUseId] = message;
        }
      }
    }

    final List<PupauMessage> sortedDocuments =
        latestDocumentByToolUseId.values.toList()..sort(
          (PupauMessage a, PupauMessage b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    final List<PupauMessage> sortedWebSection =
        latestWebSectionByToolUseId.values.toList()..sort(
          (PupauMessage a, PupauMessage b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    final List<PupauMessage> sortedNativeDatabase =
        latestNativeDatabaseByToolUseId.values.toList()..sort(
          (PupauMessage a, PupauMessage b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    final List<PupauMessage> sortedTerminal =
        latestTerminalByToolUseId.values.toList()..sort(
          (PupauMessage a, PupauMessage b) =>
              b.createdAt.compareTo(a.createdAt),
        );

    final List<PupauMessage> sortedMail = latestMailByToolUseId.values.toList()
      ..sort(
        (PupauMessage a, PupauMessage b) => b.createdAt.compareTo(a.createdAt),
      );

    final List<PupauMessage> sortedSmtp = latestSmtpByToolUseId.values.toList()
      ..sort(
        (PupauMessage a, PupauMessage b) => b.createdAt.compareTo(a.createdAt),
      );

    latestTodoListMessage.value = latestTodo;
    latestDocumentMessages.value = sortedDocuments;
    latestWebSectionMessages.value = sortedWebSection;
    latestNativeDatabaseMessages.value = sortedNativeDatabase;
    latestTerminalMessages.value = sortedTerminal;
    latestMailToolMessages.value = sortedMail;
    latestSmtpToolMessages.value = sortedSmtp;
  }
}
