import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/chat_images_list.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/graph_info_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/organic_info_container.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_news_list.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

class WebSearchElements extends StatelessWidget {
  const WebSearchElements(
      {super.key,
      required this.organicInfo,
      required this.graphInfo,
      required this.images,
      required this.news,
      required this.isAnonymous,
      required this.isCanceled});

  final List<OrganicInfo> organicInfo;
  final GraphInfo? graphInfo;
  final List<WebSearchImage> images;
  final List<WebSearchNews> news;
  final bool isAnonymous;
  final bool isCanceled;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (organicInfo.isNotEmpty)
          OrganicInfoContainer(
              organicInfo: organicInfo,
              isAnonymous: isAnonymous,
              isCancelled: isCanceled),
        if (graphInfo != null)
          GraphInfoContainer(
              graphInfo: graphInfo!,
              isAnonymous: isAnonymous,
              isCancelled: isCanceled),
        if (images.isNotEmpty)
          ChatImagesList(
              imagesUrl:
                  images.map((WebSearchImage image) => image.imageUrl).toList(),
              isAnonymous: isAnonymous),
        if (news.isNotEmpty)
          WebSearchNewsList(news: news, isAnonymous: isAnonymous)
      ],
    );
  }
}
