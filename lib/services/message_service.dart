import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class MessageService {
  static PupauMessage getUserLoadedMessage(PupauMessage message) =>
      PupauMessage(
        id: message.id,
        answer: message.answer,
        query: message.query,
        groupId: message.groupId,
        status: MessageStatus.sent,
        createdAt: message.createdAt,
        assistantId: "",
        assistantType: message.assistantType,
        isAudioInput: message.isAudioInput,
        transcription: message.transcription,
      );

  static PupauMessage getAssistantLoadedMessage(PupauMessage message) =>
      PupauMessage(
        id: message.id,
        answer: message.answer,
        query: message.query,
        assistantId: message.assistantId,
        assistantType: message.assistantType,
        groupId: message.groupId,
        status: message.status == MessageStatus.error
            ? MessageStatus.error
            : MessageStatus.received,
        createdAt: message.createdAt,
        kbReferences: message.kbReferences,
        reaction: message.reaction,
        webBased: message.webBased,
        contextInfo: message.contextInfo,
        organicInfo: message.organicInfo,
        images: message.images,
        news: message.news,
        graphInfo: message.graphInfo,
        relatedSearches: message.relatedSearches,
        toolUseMessage: message.toolUseMessage,
        toolUseAgent: message.toolUseAgent,
        sourceType: message.sourceType,
        uiToolMessage: message.uiToolMessage,
        type: message.type,
        isInitialMessage: message.isInitialMessage,
        isExternalSearch: message.isExternalSearch,
        isCancelled: message.isCancelled,
        isNarrating: message.isNarrating,
        urls: message.urls,
        attachments: message.attachments,
      );

  static void checkSSEErrors(PupauMessage message) {
    if (hasCreditsError(message)) {
      showErrorSnackbar(Strings.creditsEndedTitle.tr);
      Get.find<ChatController>().manageCancelAndErrorMessage();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.noCredit,
          payload: {"info": "Credits ended"},
        ),
      );
    } else if (hasGenericError(message)) {
      showErrorSnackbar(message.error!);
      Get.find<ChatController>().manageCancelAndErrorMessage();
      PupauEventService.instance.emitPupauEvent(
        PupauEvent(
          type: UpdateConversationType.error,
          payload: {
            "error": message.error!,
            "assistantId": message.assistantId,
            "assistantType": message.assistantType,
            "conversationId": message.groupId,
          },
        ),
      );
    } else if (message.type == MessageType.noVisionCapability) {
      Get.find<ChatController>().manageNoVisionCapability();
    }
    if (message.forbidden != null) {
      showErrorSnackbar(message.forbidden!);
    }
  }

  static bool hasCreditsError(PupauMessage message) =>
      message.type == MessageType.error && message.code == 5;

  static bool hasGenericError(PupauMessage message) =>
      message.error != null && message.type != MessageType.noDocument;

  static bool canEnableExternalSearch(
    PupauMessage message,
    bool isExternalSearch,
  ) => message.type == MessageType.noDocument && !isExternalSearch;

  static String generateMultiAgentMessage(
    String message,
    List<Assistant> taggedAssistant,
  ) {
    for (Assistant assistant in taggedAssistant) {
      if (message.contains("@${assistant.name}")) {
        message = message.replaceFirst(
          "@${assistant.name}",
          TagService.getAssistantTag(assistant),
        );
      } else {
        message += " ${TagService.getAssistantTag(assistant)}";
      }
    }
    return message;
  }
}
