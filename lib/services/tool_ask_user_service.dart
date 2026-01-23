import 'dart:convert';
import 'package:flutter_agent_pupau/models/conversation_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_ask_user_data.dart';

class ToolAskUserService {
  static Future<Stream<SSEModel>?> answerAskUserTool(
    String messageId,
    List<AskUserChoice> options,
    String? answer,
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

    String url = ApiUrls.toolQuestionUrl(
      assistantId,
      conversation.id,
      message.id,
      isMarketplace: isMarketplace,
    );
    Stream<SSEModel> messageSendStream = SSEClient.subscribeToSSE(
      method: SSERequestType.POST,
      url: url,
      header: {
        ...authParams,
        "Conversation-Token": conversation.token,
        "Content-type": "Application/json",
      },
      body: {"request": generateAnswerBody(options, answer)},
    );
    return messageSendStream;
  }

  static String generateAnswerBody(
    List<AskUserChoice> options,
    String? answer,
  ) {
    if (options.isNotEmpty) {
      List<int> indices = options.asMap().keys.toList();
      List<String> values = options.map((option) => option.choice).toList();
      return jsonEncode({
        "choice": {"index": indices, "value": values},
      });
    } else if (answer != null) {
      return jsonEncode({
        "choice": {"value": answer},
      });
    } else {
      return jsonEncode({"choice": {}});
    }
  }
}
