import 'dart:convert';

import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:get/get.dart';

class SSEService {
  static Future<Stream<SSEModel>?> createSSEStrean(
    String assistantId,
    String conversationId,
    String conversationToken,
    String message, {
    bool isWebSearch = false,
    bool isExternalSearch = false,
    ChatController? chatController,
  }) async {
    try {
      // Getting authentication credentials from the config
      final Map<String, String>? authParams =
          chatController?.pupauConfig?.authHeaders;
      if (authParams == null) return null;

      // Generating query parameters
      String queryParams = "";
      List<String> params = [];
      if (chatController?.pupauConfig?.isAnonymous ?? false) {
        params.add(
          "encryptionPass=${PupauSharedPreferences.getAnonymousConversationKey()}",
        );
      }
      if (isExternalSearch) {
        params.add("override=true");
      }
      if (isWebSearch) {
        params.add("websearch=true");
      }
      if (chatController?.pupauConfig?.customProperties != null) {
        params.add(
          "customProperties=${jsonEncode(chatController?.pupauConfig?.customProperties)}",
        );
      }
      if (params.isNotEmpty) {
        queryParams = "&${params.join('&')}";
      }

      // Generating URL
      String url =
          "${ApiUrls.sendQueryUrl(assistantId, conversationId)}$queryParams";

      // Creating SSE stream
      Stream<SSEModel> messageSendStream = SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: url,
        header: {
          ...authParams,
          "Conversation-Token": conversationToken,
          "Content-type": "Application/json",
        },
        body: generateBody(message),
      );
      return messageSendStream;
    } catch (e) {
      return null;
    }
  }

  static Map<String, dynamic> generateBody(String message) {
    List<Attachment> attachments = Get.find<AttachmentsController>().attachments
        .where((Attachment attachment) => attachment.active)
        .toList();
    if (attachments.isEmpty) {
      return {"request": message};
    } else {
      return {
        "request": message,
        "attachments": attachments
            .map((attachment) => {"id": attachment.id, "mode": "STANDARD"})
            .toList(),
      };
    }
  }
}
