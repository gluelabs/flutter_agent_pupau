import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class GraphInfoContainer extends StatelessWidget {
  const GraphInfoContainer({
    super.key,
    required this.graphInfo,
    required this.isAnonymous,
    required this.isCancelled,
  });

  final GraphInfo graphInfo;
  final bool isAnonymous;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    List<Map<String, String>> attributes = graphInfo.attributes;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isAnonymous
                  ? Colors.transparent
                  : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed),
          color:
              StyleService.getBubbleColor(true, isAnonymous, isCancelled)),
      child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: graphInfo.imageUrl.endsWith('.svg')
                        ? CachedNetworkSVGImage(graphInfo.imageUrl,
                            width: isTablet ? 150 : 95,
                            height: isTablet ? 150 : 95,
                            colorFilter: ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                            errorWidget: Image.asset(
                              Constants.missingImage,
                            ),
                            fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: graphInfo.imageUrl,
                            width: isTablet ? 150 : 95,
                            height: isTablet ? 150 : 95,
                            errorListener: (error) => print,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) => Image.asset(
                              Constants.missingImage,
                            ),
                          ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(graphInfo.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: isTablet ? 17 : 15,
                                color: isAnonymous
                                    ? Colors.white
                                    : MyStyles.pupauTheme(!Get.isDarkMode)
                                        .darkBlue,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(graphInfo.description,
                    style: TextStyle(fontSize: isTablet ? 16 : 14)),
              ),
              if (attributes.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (Map<String, String> attribute in attributes)
                      for (MapEntry<String, String> entry
                          in attribute.entries)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${entry.key}: ',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: isAnonymous
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                                ),
                                TextSpan(
                                  text: entry.value,
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: isAnonymous
                                        ? Colors.white
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                )
            ],
          )),
    );
  }
}
