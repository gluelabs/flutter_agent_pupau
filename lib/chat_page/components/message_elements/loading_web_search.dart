import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/web_search_type_indicator.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

class LoadingWebSearch extends GetView<ChatController> {
  const LoadingWebSearch({
    super.key,
    required this.loadingMessage,
  });

  final String loadingMessage;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      WebSearchType? webSearchType = controller.currentWebSearchType.value;
      return Padding(
        padding: const EdgeInsets.only(left: 20, top: 12, right: 6),
        child: Row(
          children: [
            if (webSearchType != null)
              WebSearchTypeIndicator(webSearchType: webSearchType),
            Expanded(child: Text("${controller.loadingMessage.value.message}...")),
          ],
        ),
      );
    });
  }
}
