import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachments_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/attachments_elements/attachment_note_modal.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';

class AttachmentsController extends GetxController {
  RxList<Attachment> attachments = <Attachment>[].obs;
  RxInt sendingAttachments = 0.obs;
  RxBool allAttachmentsDisabled = false.obs;
  RxString searchAttachmentsText = "".obs;
  RxList<Attachment> filteredAttachments = <Attachment>[].obs;
  TextEditingController searchAttachmentsController = TextEditingController();
  int lengthToShowNoAttachments = 5;
  RxString noteName = "".obs;
  RxString noteContent = "".obs;
  TextEditingController noteNameController = TextEditingController();
  TextEditingController noteContentController = TextEditingController();
  Rxn<Attachment> openAttachmentNote = Rxn<Attachment>();
  RxBool isSavingAttachmentNote = false.obs;
  RxList<String> downloadingAttachments = <String>[].obs;

  List<Attachment> get getAttachments => attachments;

  Future<void> loadAttachments() async {
    attachments.value = await AttachmentService.getAttachments();
    attachments.refresh();
    update();
  }

  void clearAttachments() {
    attachments.clear();
    attachments.refresh();
    update();
  }

  Future<void> getAttachmentFromDevice() async {
    List<File>? files = await FileService.getFileFromDevice(
      allowMultiple: true,
    );
    if (files.isEmpty) return;
    sendingAttachments.value = sendingAttachments.value + files.length;
    update();
    try {
      bool conversationExists = await checkConversationExists(files.length);
      if (!conversationExists) return;
      for (File file in files) {
        Attachment? newAttachment = await AttachmentService.postAttachment(
          file,
        );
        if (newAttachment != null) attachments.add(newAttachment);
        if (sendingAttachments.value <= 0) {
          sendingAttachments.value = 0;
        } else {
          sendingAttachments.value--;
        }
        attachments.refresh();
        update();
      }
      if (files.length > 1) {
        showFeedbackSnackbar(
          Strings.attachmentUploadSuccessMultiple.tr,
          Symbols.attachment,
        );
      } else {
        showFeedbackSnackbar(
          Strings.attachmentUploadSuccess.tr,
          Symbols.attachment,
        );
      }
    } catch (e) {
      sendingAttachments.value = 0;
      update();
    }
  }

  Future<void> getAttachmentFromGallery() async {
    List<Uint8ListWithName> imageFromGallery =
        await FileService.getImageFromGallery(allowMultiple: true);
    if (imageFromGallery.isEmpty) return;
    uploadAttachmentFromImage(imageFromGallery);
  }

  Future<void> getAttachmentFromCamera() async {
    Uint8ListWithName? imageFromCamera = await FileService.getImageFromCamera();
    if (imageFromCamera == null) return;
    uploadAttachmentFromImage([imageFromCamera]);
  }

  Future<void> uploadAttachmentFromImage(List<Uint8ListWithName> images) async {
    sendingAttachments.value = sendingAttachments.value + images.length;
    update();
    try {
      bool conversationExists = await checkConversationExists(images.length);
      if (!conversationExists) return;
      Directory tempDir = await getTemporaryDirectory();
      for (Uint8ListWithName image in images) {
        ByteBuffer buffer = image.image.buffer;
        ByteData byteData = ByteData.view(buffer);
        File file = await File('${tempDir.path}/${image.name}').writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        Attachment? newAttachment = await AttachmentService.postAttachment(
          file,
        );
        if (newAttachment != null) attachments.add(newAttachment);
        sendingAttachments.value--;
        update();
      }
      if (images.length > 1) {
        showFeedbackSnackbar(
          Strings.attachmentUploadSuccessMultiple.tr,
          Symbols.attachment,
        );
      } else {
        showFeedbackSnackbar(
          Strings.attachmentUploadSuccess.tr,
          Symbols.attachment,
        );
      }
    } catch (e) {
      sendingAttachments.value = sendingAttachments.value - images.length;
      update();
    }
  }

  void toggleAttachment(Attachment attachment, bool active) {
    attachments[attachments.indexOf(attachment)].active = active;
    attachments.refresh();
    allAttachmentsDisabled.value = !attachments.any(
      (Attachment attachment) => attachment.active,
    );
    update();
  }

  List<Attachment> getMessageAttachments(PupauMessage message) {
    List<PupauMessage> messages = Get.find<ChatController>().messages;
    List<Attachment> messageAttachments = [];
    List<PupauMessage> userMessages = messages
        .where((PupauMessage message) => message.status == MessageStatus.sent)
        .toList();
    if (userMessages.isEmpty) return [];
    int messageIndex = userMessages.indexWhere(
      (PupauMessage thisMessage) => thisMessage.id == message.id,
    );
    if (messageIndex == userMessages.length - 1) {
      messageAttachments = attachments
          .where((Attachment attachment) => attachment.previousQueryId == "")
          .toList();
    } else {
      PupauMessage nextMessage = userMessages[messageIndex + 1];
      messageAttachments = attachments
          .where(
            (Attachment attachment) =>
                attachment.previousQueryId == nextMessage.id,
          )
          .toList();
    }
    for (Attachment attachment in messageAttachments) {
      attachment.isShown = true;
    }
    return messageAttachments;
  }

  void toggleAllAttachments() {
    allAttachmentsDisabled.value = !allAttachmentsDisabled.value;
    for (Attachment attachment in attachments) {
      attachment.active = !allAttachmentsDisabled.value;
    }
    attachments.refresh();
    update();
  }

  Future<void> deleteAttachment(String attachmentId) async {
    bool success = await AttachmentService.deleteAttachment(attachmentId);
    if (success) {
      attachments.removeWhere(
        (Attachment attachment) => attachment.id == attachmentId,
      );
      filteredAttachments.removeWhere(
        (Attachment attachment) => attachment.id == attachmentId,
      );
      if (attachments.length < lengthToShowNoAttachments) {
        searchAttachments("");
        searchAttachmentsController.clear();
      }
      filteredAttachments.refresh();
      attachments.refresh();
      update();
    }
  }

  void searchAttachments(String? query) {
    searchAttachmentsText.value = query ?? "";
    if (query == null || query.isEmpty) {
      filteredAttachments.value = attachments;
    }
    if (query != null && query.isNotEmpty) {
      filteredAttachments.value = attachments
          .where(
            (Attachment attachment) =>
                (attachment.fileName.toLowerCase().trim().contains(
                  query.toLowerCase().trim(),
                ) ||
                attachment.link.toLowerCase().trim().contains(
                  query.toLowerCase().trim(),
                )),
          )
          .toList();
    }
    filteredAttachments.refresh();
    update();
  }

  void openAttachmentsModal() {
    BuildContext? safeContext = getSafeModalContext();
    if (safeContext != null) FocusScope.of(safeContext).unfocus();
    searchAttachmentsController.clear();
    searchAttachments("");
    showAttachmentsModal();
  }

  void setNoteName(String name) {
    noteName.value = name.trim();
    update();
  }

  void setNoteContent(String content) {
    noteContent.value = content.trim();
    update();
  }

  Future<void> openAttachmentNoteModal(
    Attachment? attachment, {
    bool isEditable = true,
  }) async {
    noteName.value = attachment?.fileName ?? "";
    if (attachment != null) {
      try {
        attachment.isLoadingContent = true;
        attachments.refresh();
        update();
        String? content = await AttachmentService.readAttachmentContent(
          attachment.id,
        );
        noteContent.value = content ?? "";
        attachment.isLoadingContent = false;
        update();
        attachments.refresh();
      } catch (e) {
        attachment.isLoadingContent = false;
        noteContent.value = "";
        attachments.refresh();
        update();
      }
    } else {
      noteContent.value = "";
    }
    noteNameController.text = noteName.value;
    noteContentController.text = noteContent.value;
    openAttachmentNote.value = attachment;
    update();
    showAttachmentNoteModal(isEditable: isEditable);
  }

  bool canSaveAttachmentNote() =>
      noteName.value.isNotEmpty && noteContent.value.isNotEmpty;

  Future<void> saveAttachmentNote(BuildContext context) async {
    try {
      isSavingAttachmentNote.value = true;
      sendingAttachments.value++;
      update();
      bool conversationExists = await checkConversationExists(1);
      if (!conversationExists) return;
      Attachment? attachment = openAttachmentNote.value == null
          ? await AttachmentService.postNoteAttachment(
              noteName.value,
              noteContent.value,
            )
          : await AttachmentService.patchNoteAttachment(
              openAttachmentNote.value!.id,
              noteName.value,
              noteContent.value,
            );
      if (attachment != null) {
        if (openAttachmentNote.value == null) {
          attachments.add(attachment);
        } else {
          attachments[attachments.indexOf(openAttachmentNote.value!)] =
              attachment;
        }
        attachments.refresh();
        update();
      }
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      isSavingAttachmentNote.value = false;
      sendingAttachments.value--;
      update();
    } catch (e) {
      isSavingAttachmentNote.value = false;
      update();
    }
  }

  Future<bool> checkConversationExists(int attachmentsLength) async {
    try {
      ChatController chatController = Get.find<ChatController>();
      if (chatController.conversation.value == null) {
        await chatController.createNewConversation();
        if (chatController.conversation.value == null) {
          chatController.resetConversation();
          sendingAttachments.value -= attachmentsLength;
          update();
          return false;
        }
        return true;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  String get getOpenAttachmentName {
    Attachment? attachment = openAttachmentNote.value;
    final String fileName = attachment?.fileName ?? "";
    final int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex > 0 &&
        dotIndex < fileName.length - 1 &&
        attachment?.extension == fileName.substring(dotIndex + 1)) {
      return fileName.substring(0, dotIndex);
    }
    return fileName;
  }

  Future<void> downloadAttachment(String attachmentId) async {
    downloadingAttachments.add(attachmentId);
    update();

    try {
      Attachment? attachment = attachments.firstWhereOrNull(
        (attachment) => attachment.id == attachmentId,
      );
      if (attachment == null) {
        await Future.delayed(const Duration(seconds: 3));
        attachment = attachments.firstWhereOrNull(
          (attachment) => attachment.id == attachmentId,
        );
      }
      if (attachment == null) return;
      await AttachmentService.downloadAttachment(attachment);
      downloadingAttachments.remove(attachmentId);
      update();
    } catch (e) {
      downloadingAttachments.remove(attachmentId);
      update();
    }
  }
}
