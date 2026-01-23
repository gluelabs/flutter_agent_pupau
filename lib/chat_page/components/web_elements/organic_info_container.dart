import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/organic_info_modal.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class OrganicInfoContainer extends StatelessWidget {
  const OrganicInfoContainer({
    super.key,
    required this.organicInfo,
    required this.isAnonymous,
    required this.isCancelled
  });

  final List<OrganicInfo> organicInfo;
  final bool isAnonymous;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: isAnonymous
                    ? Colors.transparent
                    : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed),
            color:
                StyleService.getBubbleColor(true, isAnonymous, isCancelled)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => showOrganicInfoModal(organicInfo),
            child: Padding(
                padding: const EdgeInsets.all(6),
                child: SizedBox(
                  width: (organicInfo.length * 18) + (isTablet ? 12 : 8),
                  height: isTablet ? 32 : 28,
                  child: Stack(
                    children: [
                      for (int i = 0; i < organicInfo.length; i++)
                        Positioned(
                            left: 0 + i * 18,
                            top: 0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                  imageUrl: ConversationService.getFaviconUrl(
                                      organicInfo[i].link),
                                  width: isTablet ? 32 : 28,
                                  height: isTablet ? 32 : 28,
                                  errorListener: (error) => print,
                                  errorWidget: (context, url, error) =>
                                      Image.asset(Constants.missingImage)),
                            )
                            //
                            ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
