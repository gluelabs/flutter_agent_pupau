import 'package:cached_network_image/cached_network_image.dart';
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

class SourceInfo extends StatelessWidget {
  final OrganicInfo organicInfo;
  const SourceInfo({
    super.key,
    required this.organicInfo,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: CachedNetworkImage(
                    imageUrl:
                        ConversationService.getFaviconUrl(organicInfo.link),
                    width: isTablet ? 32 : 28,
                    height: isTablet ? 32 : 28,
                    errorListener: (e) => print,
                    errorWidget: (context, url, error) =>
                        Image.asset(Constants.missingImage)),
              ),
              const SizedBox(width: 8),
              Expanded(
                  child: InkWell(
                onTap: () => DeviceService.openLink(organicInfo.link),
                child: Text(organicInfo.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isTablet ? 15 : 13,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).blue,
                      decoration: TextDecoration.underline,
                      decorationColor:
                          MyStyles.pupauTheme(!Get.isDarkMode).blue,
                    )),
              )),
              IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: organicInfo.link));
                    showFeedbackSnackbar(
                        Strings.copiedClipboard.tr, Symbols.content_copy,
                        isInfo: true);
                  },
                  icon: Icon(Symbols.content_copy,
                      size: isTablet ? 26 : 24,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).blue)),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -4),
            child: Text(organicInfo.snippet,
                maxLines: 2, style: TextStyle(fontSize: isTablet ? 15 : 13)),
          ),
        ],
      ),
    );
  }
}
