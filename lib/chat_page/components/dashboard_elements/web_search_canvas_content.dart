import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_elements.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_web_search_data.dart';
import 'package:get/get.dart';

class WebSearchCanvasContent extends StatelessWidget {
  const WebSearchCanvasContent({super.key, required this.toolUseMessage});

  final ToolUseMessage toolUseMessage;

  @override
  Widget build(BuildContext context) {
    final ToolUseWebSearchData? data = toolUseMessage.webSearchData;
    final List<OrganicInfo> organicInfo = data?.organicInfo ?? [];
    final GraphInfo? graphInfo = data?.graphInfo;
    final List<WebSearchImage> images = data?.images ?? [];
    final List<WebSearchNews> news = data?.news ?? [];
    final bool isAnonymous = Get.find<PupauChatController>().isAnonymous;
    return WebSearchElements(
      organicInfo: organicInfo,
      graphInfo: graphInfo,
      images: images,
      news: news,
      isAnonymous: isAnonymous,
      isCanceled: false,
    );
  }
}
