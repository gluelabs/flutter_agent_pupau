import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/news_container.dart';

class WebSearchNewsList extends GetView<ChatController> {
  const WebSearchNewsList({
    super.key,
    required this.news,
    this.isAnonymous = false,
    this.hideHeader = false,
  });

  final List<WebSearchNews> news;
  final bool isAnonymous;
  final bool hideHeader;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 18),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            if (!hideHeader)
              Row(
                children: [
                  Icon(Symbols.news,
                      size: isTablet ? 26 : 24,
                      color: isAnonymous
                          ? AnonymousThemeColors.assistantText
                          : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
                  const SizedBox(width: 6),
                  Text(Strings.news.tr,
                      style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w500,
                          color: isAnonymous
                              ? AnonymousThemeColors.assistantText
                              : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue)),
                ],
              ),
            ...news.map((news) => NewsContainer(news: news))
          ]),
    );
  }
}
