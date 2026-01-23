import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

class ChatImagesList extends GetView<ChatController> {
  const ChatImagesList({
    super.key,
    required this.imagesUrl,
    this.isAnonymous = false,
    this.hideHeader = false,
  });

  final List<String> imagesUrl;
  final bool isAnonymous;
  final bool hideHeader;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hideHeader)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Symbols.image,
                    size: isTablet ? 26 : 24,
                    color: isAnonymous
                        ? AnonymousThemeColors.assistantText
                        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    Strings.media.tr,
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isAnonymous
                          ? AnonymousThemeColors.assistantText
                          : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: imagesUrl
                  .map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () =>
                              controller.selectImage(url, ImageType.url),
                          child: url.endsWith(".svg")
                              ? CachedNetworkSVGImage(
                                  url,
                                  width: isTablet ? 200 : 125,
                                  height: isTablet ? 200 : 125,
                                  colorFilter: ColorFilter.mode(
                                    Colors.white,
                                    BlendMode.srcIn,
                                  ),
                                  errorWidget: Image.asset(
                                    Constants.missingImage,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: url,
                                  width: isTablet ? 200 : 125,
                                  height: isTablet ? 200 : 125,
                                  fit: BoxFit.cover,
                                  errorListener: (error) => print,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                        Constants.missingImage,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
