import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
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
  static Future<Attachment?> postAttachment(
    File file, {
    bool isNote = false,
  }) async {
    Attachment? attachment;
    PupauChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken = chatController.conversation.value?.token ?? "";
    dio.FormData formData = dio.FormData.fromMap({
      "type": isNote ? "NOTE" : FileService.getFileType(file.path),
      "file": dio.MultipartFile.fromBytes(
        file.readAsBytesSync(),
        filename: basename(file.path),
      ),
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
          "${Strings.apiErrorGeneric.tr} ${Strings.attachmentUploadFailed.tr}",
        ),
      );
      return attachment;
    }
    return null;
  }

  static Future<Attachment?> patchAttachment(
    String idAttachment,
    String fileName,
    File file, {
    bool isNote = false,
  }) async {
    Attachment? attachment;
    PupauChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken = chatController.conversation.value?.token ?? "";
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
          idAssistant,
          idConversation,
          idAttachment,
        ),
        RequestType.patch,
        data: formData,
        headers: {
          "Content-Type": "multipart/form-data",
          "Conversation-Token": conversationToken,
        },
        onSuccess: (response) => attachment = Attachment.fromMap(response.data),
        onError: (e) => showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.attachmentUploadFailed.tr}",
        ),
      );
      return attachment;
    }
    return null;
  }

  static Future<List<Attachment>> getAttachments() async {
    List<Attachment> attachments = [];
    PupauChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken = chatController.conversation.value?.token ?? "";
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
    PupauChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken = chatController.conversation.value?.token ?? "";
    await ApiService.call(
      ApiUrls.conversationAttachmentUrl(
        idAssistant,
        idConversation,
        idAttachment,
      ),
      RequestType.delete,
      headers: {"Conversation-Token": conversationToken},
      onSuccess: (response) {
        success = true;
        _imageBytesCache.remove(idAttachment);
        showFeedbackSnackbar(Strings.resourceDeletedSuccess.tr, Symbols.delete);
      },
      onError: (e) => showErrorSnackbar(Strings.apiErrorGeneric.tr),
    );
    return success;
  }

  static AttachmentCategory getAttachmentCategory(Attachment attachment) {
    if (attachment.link != "") return AttachmentCategory.link;
    // `fileName` never carries the extension (it's assembled separately as
    // `'$fileName.$extension'` everywhere else, e.g. dashboard_canvas_item.dart)
    // — matching on `attachment.extension` instead of `extension(fileName)`.
    switch (attachment.extension.toLowerCase()) {
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
      case 'gif':
      case 'heic':
      case 'heif':
        return AttachmentCategory.image;
      default:
        return AttachmentCategory.document;
    }
  }

  static int getTokensUsed(List<Attachment> attachments) => attachments.fold(
    0,
    (acc, attachment) => acc + (attachment.selected ? attachment.tokens : 0),
  );

  static Future<Attachment?> postNoteAttachment(
    String title,
    String content,
  ) async {
    File? file = await FileService.createMdFile(title, content);
    if (file == null) return null;
    return await postAttachment(file, isNote: true);
  }

  static Future<Attachment?> patchNoteAttachment(
    String idAttachment,
    String title,
    String content,
  ) async {
    File? file = await FileService.createMdFile(title, content);
    if (file == null) return null;
    return await patchAttachment(idAttachment, title, file, isNote: true);
  }

  static Future<Attachment?> patchAttachmentSelected(
    String idAttachment,
    bool selected,
  ) async {
    Attachment? attachment;
    PupauChatController chatController = Get.find();
    String idConversation = chatController.conversation.value?.id ?? "";
    String idAssistant = chatController.assistant.value?.id ?? "";
    String conversationToken = chatController.conversation.value?.token ?? "";

    if (idAssistant != "" && idConversation != "" && conversationToken != "") {
      await ApiService.call(
        ApiUrls.conversationAttachmentUrl(
          idAssistant,
          idConversation,
          idAttachment,
        ),
        RequestType.patch,
        data: {"selected": selected},
        headers: {"Conversation-Token": conversationToken},
        onSuccess: (response) => attachment = Attachment.fromMap(response.data),
        onError: (e) => showErrorSnackbar(
          "${Strings.apiErrorGeneric.tr} ${Strings.attachmentUploadFailed.tr}",
        ),
      );
      return attachment;
    }
    return null;
  }

  static Future<String?> readAttachmentContent(String idAttachment) async {
    try {
      String content = "";
      PupauChatController chatController = Get.find();
      String idConversation = chatController.conversation.value?.id ?? "";
      String idAssistant = chatController.assistant.value?.id ?? "";
      String conversationToken = chatController.conversation.value?.token ?? "";
      await ApiService.call(
        ApiUrls.conversationAttachmentViewUrl(
          idAssistant,
          idConversation,
          idAttachment,
        ),
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

  /// In-memory, app-lifetime cache of decoded attachment image bytes, keyed
  /// by attachment id — attachments are immutable once uploaded, so once
  /// fetched a byte array never goes stale and reopening the same image in
  /// the dashboard canvas shouldn't re-hit the network.
  static final Map<String, Uint8List> _imageBytesCache = <String, Uint8List>{};

  /// Same endpoint as [readAttachmentContent] but read as raw bytes —
  /// needed for image previews, since the generic `ApiService.call` path
  /// decodes every response as text/JSON and would corrupt binary data.
  static Future<Uint8List?> readAttachmentImageBytes(
    String idAttachment,
  ) async {
    final Uint8List? cached = _imageBytesCache[idAttachment];
    if (cached != null) return cached;
    try {
      PupauChatController chatController = Get.find();
      String idConversation = chatController.conversation.value?.id ?? "";
      String idAssistant = chatController.assistant.value?.id ?? "";
      String conversationToken = chatController.conversation.value?.token ?? "";
      final dio.Response<List<int>> response = await ApiService.dio
          .get<List<int>>(
            ApiUrls.conversationAttachmentViewUrl(
              idAssistant,
              idConversation,
              idAttachment,
            ),
            options: dio.Options(
              headers: {"Conversation-Token": conversationToken},
              responseType: dio.ResponseType.bytes,
            ),
          );
      final List<int>? bytes = response.data;
      if (bytes == null) return null;
      final Uint8List result = Uint8List.fromList(bytes);
      _imageBytesCache[idAttachment] = result;
      return result;
    } catch (e) {
      return null;
    }
  }

  static Future<void> downloadAttachment(Attachment? attachment) async {
    if (attachment == null) return;
    String? content = await readAttachmentContent(attachment.id);
    if (content == null) return;
    FileService.saveToDownloads(
      content,
      attachment.fileName,
      attachment.extension,
    );
  }
}

enum AttachmentCategory { document, image, link }
