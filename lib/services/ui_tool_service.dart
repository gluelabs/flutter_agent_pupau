import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/google_drive_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class UiToolService {
  static Future<Stream<SSEModel>?> approveTool(String messageId) async {
    ChatController chatController = Get.find();
    String? assistantId = chatController.assistant.value?.id;
    Conversation? conversation = chatController.conversation.value;
    if (assistantId == null || conversation == null) return null;

    PupauMessage message = chatController.messages.firstWhere(
      (element) => element.id == messageId,
    );
    bool isMarketplace = chatController.isMarketplace;

    final Map<String, String>? authParams = chatController.pupauConfig?.authHeaders;
    if (authParams == null) return null;

    String queryParams = "";
    List<String> params = [];
    if (params.isNotEmpty) {
      queryParams = "&${params.join('&')}";
    }
    String url =
        "${ApiUrls.toolApprovalUrl(assistantId, conversation.id, message.id, isMarketplace: isMarketplace)}$queryParams";
    Stream<SSEModel> messageSendStream = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: {
        ...authParams,
        "Conversation-Token": conversation.token,
        "Content-type": "Application/json",
      },
      body: {"request": message.answer},
    );
    return messageSendStream;
  }

  static Future<Stream<SSEModel>?> authorizeTool(
    String messageId,
    String toolId,
  ) async {
    ChatController chatController = Get.find();
    String? assistantId = chatController.assistant.value?.id;
    Conversation? conversation = chatController.conversation.value;
    if (assistantId == null || conversation == null) return null;

    PupauMessage message = chatController.messages.firstWhere(
      (element) => element.id == messageId,
    );
    bool isMarketplace = chatController.isMarketplace;

    final Map<String, String>? authParams = chatController.pupauConfig?.authHeaders;
    if (authParams == null) return null;

    String queryParams = "";
    List<String> params = [];
    if (params.isNotEmpty) {
      queryParams = "&${params.join('&')}";
    }
    String? authCode = await GoogleDriveService.requestGoogleDriveAuth();
    if (authCode == null) return null;
    String url =
        "${ApiUrls.toolAuthUrl(assistantId, conversation.id, message.id, toolId, authCode, isMarketplace: isMarketplace)}$queryParams";
    Stream<SSEModel> messageSendStream = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: {
        ...authParams,
        "Conversation-Token": conversation.token,
        "Content-type": "Application/json",
      },
      body: {"request": message.answer},
    );
    return messageSendStream;
  }

  static UiToolType getUiToolTypeEnum(String type) {
    switch (type) {
      case "AUTHORIZE_TOOL":
        return UiToolType.authorizeTool;
      case "REQUEST_CREDENTIALS":
        return UiToolType.requestCredentials;
      default:
        return UiToolType.genericUiTool;
    }
  }
}

enum UiToolType { authorizeTool, requestCredentials, genericUiTool }
