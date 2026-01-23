import 'dart:convert';
import 'dart:io';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';

class AttachmentService {
  static Future<Attachment?> postAttachment(File file,
      {bool isNote = false}) async {
    Attachment? attachment;
    ChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken =
        chatController.conversation.value?.token ?? "";
    dio.FormData formData = dio.FormData.fromMap({
      "type": isNote ? "NOTE" : FileService.getFileType(file.path),
      "file": dio.MultipartFile.fromBytes(
        file.readAsBytesSync(),
        filename: basename(file.path),
      )
    });
    if (idAssistant != "" && idConversation != "" && conversationToken != "") {
      await ApiService.call(
        ApiUrls.conversationAttachmentsUrl(idAssistant, idConversation),
        RequestType.post,
        data: formData,
        headers: {
          "Content-Type": "multipart/form-data",
          "Conversation-Token": conversationToken,
        },
        onSuccess: (response) => attachment = Attachment.fromMap(response.data),
        onError: (e) => showErrorSnackbar(
            "${Strings.apiErrorGeneric.tr} ${Strings.attachmentUploadFailed.tr}"),
      );
      return attachment;
    }
    return null;
  }

  static Future<Attachment?> patchAttachment(
      String idAttachment, String fileName, File file,
      {bool isNote = false}) async {
    Attachment? attachment;
    ChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken =
        chatController.conversation.value?.token ?? "";
    dio.FormData formData = dio.FormData.fromMap({
      "type": isNote ? "NOTE" : FileService.getFileType(file.path),
      "file": dio.MultipartFile.fromBytes(
        file.readAsBytesSync(),
        filename: fileName,
      ),
      "fileName": fileName,
    });
    if (idAssistant != "" && idConversation != "" && conversationToken != "") {
      await ApiService.call(
        ApiUrls.conversationAttachmentUrl(
            idAssistant, idConversation, idAttachment),
        RequestType.patch,
        data: formData,
        headers: {
          "Content-Type": "multipart/form-data",
          "Conversation-Token": conversationToken,
        },
        onSuccess: (response) => attachment = Attachment.fromMap(response.data),
        onError: (e) => showErrorSnackbar(
            "${Strings.apiErrorGeneric.tr} ${Strings.attachmentUploadFailed.tr}"),
      );
      return attachment;
    }
    return null;
  }

  static Future<List<Attachment>> getAttachments() async {
    List<Attachment> attachments = [];
    ChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken =
        chatController.conversation.value?.token ?? "";
    if (idAssistant != "" && idConversation != "" && conversationToken != "") {
      await ApiService.call(
        ApiUrls.conversationAttachmentsUrl(idAssistant, idConversation),
        RequestType.get,
        headers: {"Conversation-Token": conversationToken},
        onSuccess: (response) {
          attachments = attachmentsFromMap(jsonEncode(response.data));
        },
        onError: (e) {},
      );
      return attachments;
    }
    return attachments;
  }

  static Future<bool> deleteAttachment(String idAttachment) async {
    bool success = false;
    ChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken =
        chatController.conversation.value?.token ?? "";
    await ApiService.call(
        ApiUrls.conversationAttachmentUrl(
            idAssistant, idConversation, idAttachment),
        RequestType.delete,
        headers: {"Conversation-Token": conversationToken},
        onSuccess: (response) {
          success = true;
          showFeedbackSnackbar(
              Strings.resourceDeletedSuccess.tr, Symbols.delete);
        },
        onError: (e) => showErrorSnackbar(Strings.apiErrorGeneric.tr));
    return success;
  }

  static AttachmentCategory getAttachmentCategory(Attachment attachment) {
    if (attachment.link != "") return AttachmentCategory.link;
    switch (extension(attachment.fileName)) {
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
      case '.gif':
        return AttachmentCategory.image;
      default:
        return AttachmentCategory.document;
    }
  }

  static int getTokensUsed(List<Attachment> attachments) => attachments.fold(0,
      (acc, attachment) => acc + (attachment.active ? attachment.tokens : 0));

  static Future<Attachment?> postNoteAttachment(
      String title, String content) async {
    File? file = await FileService.createMdFile(title, content);
    if (file == null) return null;
    return await postAttachment(file, isNote: true);
  }

  static Future<Attachment?> patchNoteAttachment(
      String idAttachment, String title, String content) async {
    File? file = await FileService.createMdFile(title, content);
    if (file == null) return null;
    return await patchAttachment(idAttachment, title, file, isNote: true);
  }

  static Future<String?> readAttachmentContent(String idAttachment) async {
    try {
      String content = "";
      ChatController chatController = Get.find();
      String idConversation = chatController.conversation.value?.id ?? "";
      String idAssistant = chatController.assistant.value?.id ?? "";
      String conversationToken =
          chatController.conversation.value?.token ?? "";
      await ApiService.call(
        ApiUrls.conversationAttachmentViewUrl(
            idAssistant, idConversation, idAttachment),
        RequestType.get,
        headers: {"Conversation-Token": conversationToken},
        onSuccess: (response) => content = response.data,
        onError: (e) => showErrorSnackbar(Strings.apiErrorGeneric.tr),
      );
      return content;
    } catch (e) {
      showErrorSnackbar(Strings.apiErrorGeneric.tr);
      return null;
    }
  }

  static Future<void> downloadAttachment(Attachment? attachment) async {
    if (attachment == null) return;
    String? content = await readAttachmentContent(attachment.id);
    if (content == null) return;
    FileService.saveToDownloads(
        content, attachment.fileName, attachment.extension);
  }
}

enum AttachmentCategory { document, image, link }
