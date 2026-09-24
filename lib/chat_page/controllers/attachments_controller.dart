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

class PupauAttachmentsController extends GetxController {
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

  /// Attachment IDs that are currently loading note content for the note modal.
  RxSet<String> attachmentIdsLoadingNoteModal = <String>{}.obs;

  /// Decoded image bytes for the attachment currently open in the dashboard
  /// canvas — only populated when that attachment is an image.
  Rxn<Uint8List> canvasImageBytes = Rxn<Uint8List>();

  /// Monotonic request id used to ignore stale note-content loads (modal).
  int _noteModalLoadRequestId = 0;

  /// Separate monotonic request id for canvas loads (independent of modal).
  int _canvasLoadRequestId = 0;

  bool isAttachmentNoteModalLoading(String attachmentId) =>
      attachmentIdsLoadingNoteModal.contains(attachmentId);

  List<Attachment> get getAttachments => attachments;

  /// Looks up an attachment by [id] in [attachments], retrying once after a
  /// short delay if it isn't there yet — covers the race where a tool (e.g.
  /// ATTACH_ARTIFACT) just created the attachment and [loadAttachments]'s
  /// refresh hasn't landed by the time the caller wants to act on it.
  Future<Attachment?> getAttachmentById(String id) async {
    Attachment? attachment = attachments.firstWhereOrNull(
      (Attachment a) => a.id == id,
    );
    if (attachment == null) {
      await Future.delayed(const Duration(seconds: 3));
      attachment = attachments.firstWhereOrNull((Attachment a) => a.id == id);
    }
    return attachment;
  }

  Future<void> loadAttachments() async {
    final List<Attachment> fresh = await AttachmentService.getAttachments();
    for (final Attachment freshAttachment in fresh) {
      final Attachment? existing = attachments.firstWhereOrNull(
        (Attachment a) => a.id == freshAttachment.id,
      );
      if (existing != null) {
        freshAttachment.selected = existing.selected;
        freshAttachment.isShown = existing.isShown;
        freshAttachment.isLoadingContent = existing.isLoadingContent;
      }
    }
    attachments.value = fresh;
    attachments.refresh();
    update();
  }

  void clearAttachments() {
    attachments.clear();
    attachments.refresh();
    update();
  }

  Future<void> getAttachmentFromDevice() async {
    final List<File> files = await FileService.getFileFromDevice(
      allowMultiple: true,
    );
    if (files.isEmpty) return;
    await uploadAttachmentFiles(files);
  }

  /// Uploads files that have already been chosen.
  ///
  /// Split out of [getAttachmentFromDevice] so the same path can be driven
  /// programmatically (see PupauChatUtils.attachFiles) without opening the
  /// system picker. Returns how many were accepted by the backend.
  Future<int> uploadAttachmentFiles(List<File> files) async {
    if (files.isEmpty) return 0;

    // Counts files still owed a decrement, so an early return or a throw can
    // never leave the pending-attachments spinner stuck on screen.
    int pending = files.length;
    void releasePending(int amount) {
      if (amount <= 0) return;
      final int next = sendingAttachments.value - amount;
      sendingAttachments.value = next < 0 ? 0 : next;
    }

    sendingAttachments.value = sendingAttachments.value + pending;
    update();
    int uploaded = 0;
    try {
      final bool conversationExists = await checkConversationExists(
        files.length,
      );
      if (!conversationExists) return 0;
      for (final File file in files) {
        final Attachment? newAttachment = await AttachmentService.postAttachment(
          file,
        );
        if (newAttachment != null) {
          attachments.add(newAttachment);
          uploaded++;
        }
        releasePending(1);
        pending--;
        attachments.refresh();
        update();
      }
      showFeedbackSnackbar(
        files.length > 1
            ? Strings.attachmentUploadSuccessMultiple.tr
            : Strings.attachmentUploadSuccess.tr,
        Symbols.attachment,
      );
    } catch (e) {
      // Swallowed as before - the caller sees the count instead.
    } finally {
      releasePending(pending);
      pending = 0;
      update();
    }
    return uploaded;
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
        File file = await File(
          '${tempDir.path}/${image.name}',
        ).writeAsBytes(image.image);
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

  Future<void> toggleAttachment(Attachment attachment, bool active) async {
    final int index = attachments.indexOf(attachment);
    if (index < 0) return;
    final bool previousSelected = attachment.selected;
    final bool previousAllDisabled = allAttachmentsDisabled.value;

    attachments[index].selected = active;
    attachments.refresh();
    allAttachmentsDisabled.value = !attachments.any(
      (Attachment a) => a.selected,
    );
    update();

    const int maxRetries = 3;
    Attachment? updatedAttachment;
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        updatedAttachment = await AttachmentService.patchAttachmentSelected(
          attachment.id,
          active,
        );
        if (updatedAttachment != null) break;
      } catch (_) {}
    }
    if (updatedAttachment == null && index < attachments.length) {
      attachments[index].selected = previousSelected;
      attachments.refresh();
      allAttachmentsDisabled.value = previousAllDisabled;
      update();
    }
  }

  List<Attachment> getMessageAttachments(PupauMessage message) {
    List<PupauMessage> messages = Get.find<PupauChatController>().messages;
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

  Future<void> toggleAllAttachments() async {
    final List<bool> previousSelected = attachments
        .map((Attachment a) => a.selected)
        .toList();

    allAttachmentsDisabled.value = !allAttachmentsDisabled.value;
    final bool newSelected = !allAttachmentsDisabled.value;
    for (Attachment attachment in attachments) {
      attachment.selected = newSelected;
    }
    attachments.refresh();
    update();

    final List<Future<bool>> futures = <Future<bool>>[];
    for (int i = 0; i < attachments.length; i++) {
      final bool prevSelected = previousSelected[i];
      if (prevSelected == newSelected) continue;

      final Attachment attachment = attachments[i];
      final int index = i;

      futures.add(() async {
        const int maxRetries = 3;
        for (int attempt = 0; attempt < maxRetries; attempt++) {
          try {
            final Attachment? result =
                await AttachmentService.patchAttachmentSelected(
                  attachment.id,
                  newSelected,
                );
            if (result != null) return true;
          } catch (_) {}
        }
        if (index < attachments.length) {
          attachments[index].selected = prevSelected;
        }
        return false;
      }());
    }

    await Future.wait(futures);
    attachments.refresh();
    allAttachmentsDisabled.value = !attachments.any(
      (Attachment a) => a.selected,
    );
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

  /// Loads attachment content and sets the controller state without opening
  /// the modal. Used by the dashboard canvas to render content inline.
  ///
  /// Adds [attachment.id] to [attachmentIdsLoadingNoteModal] synchronously
  /// before the first await so that any Obx observer immediately sees the
  /// loading state before the widget tree even builds.
  Future<void> loadAttachmentForCanvas(Attachment? attachment) async {
    _canvasLoadRequestId++;
    final int requestId = _canvasLoadRequestId;
    final String? attachmentId = attachment?.id;
    final bool isImage =
        attachment != null &&
        AttachmentService.getAttachmentCategory(attachment) ==
            AttachmentCategory.image;

    noteName.value = attachment?.fileName ?? '';
    noteContent.value = '';
    canvasImageBytes.value = null;

    // Mark as loading before the first await so Obx sees it synchronously.
    if (attachmentId != null && attachmentId.isNotEmpty) {
      attachmentIdsLoadingNoteModal.add(attachmentId);
    }

    if (attachment != null && isImage) {
      final Uint8List? bytes = await AttachmentService.readAttachmentImageBytes(
        attachment.id,
      );
      if (requestId != _canvasLoadRequestId) return;
      canvasImageBytes.value = bytes;
    } else if (attachment != null) {
      try {
        final String? content = await AttachmentService.readAttachmentContent(
          attachment.id,
        );
        if (requestId != _canvasLoadRequestId) return;
        noteContent.value = content ?? '';
      } catch (_) {
        if (requestId != _canvasLoadRequestId) return;
        noteContent.value = '';
      }
    }

    noteNameController.text = noteName.value;
    noteContentController.text = noteContent.value;
    openAttachmentNote.value = attachment;

    if (attachmentId != null && attachmentId.isNotEmpty) {
      attachmentIdsLoadingNoteModal.remove(attachmentId);
    }
    update();
  }

  Future<void> openAttachmentNoteModal(
    Attachment? attachment, {
    bool isEditable = true,
  }) async {
    final String? attachmentId = attachment?.id;
    if (attachmentId != null &&
        attachmentId.trim().isNotEmpty &&
        isAttachmentNoteModalLoading(attachmentId)) {
      return;
    }

    // Stop any other in-flight content loads (best-effort cancellation).
    _noteModalLoadRequestId++;
    final int loadRequestId = _noteModalLoadRequestId;

    noteName.value = attachment?.fileName ?? "";

    // Image attachments render as a picture, not text — load the raw bytes
    // (into [canvasImageBytes], reused by the modal) instead of the file's
    // decoded-as-text content, which is meaningless for a PNG/JPG.
    final bool isImage =
        attachment != null &&
        AttachmentService.getAttachmentCategory(attachment) ==
            AttachmentCategory.image;
    if (isImage) {
      canvasImageBytes.value = null;
      if (attachmentId != null && attachmentId.trim().isNotEmpty) {
        attachmentIdsLoadingNoteModal.add(attachmentId);
        attachmentIdsLoadingNoteModal.refresh();
      }
      openAttachmentNote.value = attachment;
      noteNameController.text = noteName.value;
      update();
      showAttachmentNoteModal(isEditable: false);

      final Uint8List? bytes = await AttachmentService.readAttachmentImageBytes(
        attachment.id,
      );
      if (loadRequestId != _noteModalLoadRequestId) return;
      canvasImageBytes.value = bytes;
      if (attachmentId != null && attachmentId.trim().isNotEmpty) {
        attachmentIdsLoadingNoteModal.remove(attachmentId);
        attachmentIdsLoadingNoteModal.refresh();
      }
      update();
      return;
    }

    if (attachment != null) {
      try {
        if (attachmentId != null && attachmentId.trim().isNotEmpty) {
          attachmentIdsLoadingNoteModal.add(attachmentId);
          attachmentIdsLoadingNoteModal.refresh();
        }

        // Clear any other loading flags so only one attachment shows loading state.
        for (final Attachment a in attachments) {
          if (a.id != attachment.id && a.isLoadingContent == true) {
            a.isLoadingContent = false;
          }
        }

        attachment.isLoadingContent = true;
        attachments.refresh();
        update();
        String? content = await AttachmentService.readAttachmentContent(
          attachment.id,
        );
        if (loadRequestId != _noteModalLoadRequestId) {
          // A newer request started; ignore this result.
          return;
        }
        noteContent.value = content ?? "";
        attachment.isLoadingContent = false;
        if (attachmentId != null && attachmentId.trim().isNotEmpty) {
          attachmentIdsLoadingNoteModal.remove(attachmentId);
          attachmentIdsLoadingNoteModal.refresh();
        }
        update();
        attachments.refresh();
      } catch (e) {
        attachment.isLoadingContent = false;
        noteContent.value = "";
        if (attachmentId != null && attachmentId.trim().isNotEmpty) {
          attachmentIdsLoadingNoteModal.remove(attachmentId);
          attachmentIdsLoadingNoteModal.refresh();
        }
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
      PupauChatController chatController = Get.find<PupauChatController>();
      // Living Agent mode has no attachment endpoints in this scope. Refuse
      // here, before createNewConversation/resetConversation below can wipe
      // the open thread.
      if (chatController.pupauConfig?.isLivingAgent ?? false) {
        sendingAttachments.value = 0;
        update();
        return false;
      }
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
      final Attachment? attachment = await getAttachmentById(attachmentId);
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
