import 'package:flutter_agent_pupau/models/pupau_message_model.dart';

class ToolUseWebSearchData {
  String query;
  String searchEngine;
  String type;
  String country;
  String language;
  List<OrganicInfo> organicInfo;
  List<WebSearchImage> images;
  List<WebSearchNews> news;

  ToolUseWebSearchData({
    required this.query,
    required this.searchEngine,
    required this.type,
    required this.country,
    required this.language,
    required this.organicInfo,
    required this.images,
    required this.news,
  });
  factory ToolUseWebSearchData.fromJson(Map<String, dynamic> json) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    if (firstInfo.isEmpty) {
      return ToolUseWebSearchData(
          query: "",
          searchEngine: "",
          type: "",
          country: "",
          language: "",
          organicInfo: [],
          images: [],
          news: []);
    }
    final searchParams = firstInfo["webSearchResponse"]?["webSearchLinksInfo"]
        ?["searchParameters"];
    return ToolUseWebSearchData(
      query: searchParams?["q"] ?? "",
      searchEngine: searchParams?["engine"] ?? "",
      type: searchParams?["type"] ?? "",
      country: searchParams?["gl"] ?? "",
      language: searchParams?["hl"] ?? "",
      organicInfo: firstInfo["webSearchResponse"]?["webSearchLinksInfo"]
                  ?["organic"] !=
              null
          ? List<OrganicInfo>.from(firstInfo["webSearchResponse"]
                  ?["webSearchLinksInfo"]?["organic"]
              .map((x) => OrganicInfo.fromMap(x)))
          : [],
      images: firstInfo["webSearchResponse"]?["webSearchLinksInfo"]
                  ?["images"] !=
              null
          ? List<WebSearchImage>.from(firstInfo["webSearchResponse"]
                  ?["webSearchLinksInfo"]?["images"]
              .map((x) => WebSearchImage.fromMap(x)))
          : [],
      news:
          firstInfo["webSearchResponse"]?["webSearchLinksInfo"]?["news"] != null
              ? List<WebSearchNews>.from(firstInfo["webSearchResponse"]
                      ?["webSearchLinksInfo"]?["news"]
                  .map((x) => WebSearchNews.fromMap(x)))
              : [],
    );
  }
}
