import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';

class NewsContainer extends StatelessWidget {
  const NewsContainer({
    super.key,
    required this.news,
  });

  final WebSearchNews news;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    double newsImageSize = isTablet ? 120 : 65;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: news.imageUrl.endsWith(".svg")
              ? CachedNetworkSVGImage(news.imageUrl,
                  width: newsImageSize,
                  height: newsImageSize,
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  errorWidget: Image.asset(
                    Constants.missingImage,
                  ),
                  fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: news.imageUrl,
                  width: newsImageSize,
                  height: newsImageSize,
                  errorListener: (error) => print,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Image.asset(
                    Constants.missingImage,
                  ),
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              spacing: 6,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: CachedNetworkImage(
                      imageUrl: ConversationService.getFaviconUrl(news.link),
                      width: isTablet ? 28 : 24,
                      height: isTablet ? 28 : 24,
                      errorListener: (e) => print,
                      errorWidget: (context, url, error) =>
                          Image.asset(Constants.missingImage)),
                ),
                Expanded(
                  child: Text(news.source,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isTablet ? 15 : 13,
                      )),
                ),
                Text(news.date,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                    )),
              ],
            ),
            InkWell(
              onTap: () => DeviceService.openLink(news.link),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: news.link));
                showFeedbackSnackbar(
                    Strings.copiedClipboard.tr, Symbols.content_copy);
              },
              borderRadius: BorderRadius.circular(4),
              child: Text(news.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: MyStyles.pupauTheme(!Get.isDarkMode).blue,
                    decoration: TextDecoration.underline,
                    decorationColor: MyStyles.pupauTheme(!Get.isDarkMode).blue,
                  )),
            ),
          ],
        )),
      ],
    );
  }
}
