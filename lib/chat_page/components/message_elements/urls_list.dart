import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class UrlsList extends StatelessWidget {
  const UrlsList({super.key, required this.urls});

  final List<UrlInfo> urls;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate((urls.length / 2).ceil(), (index) {
          return Row(
            children: [
              for (int i = 0; i < 2; i++)
                if (index * 2 + i < urls.length)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Material(
                        elevation: 0,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            try {
                              DeviceService.openLink(urls[index * 2 + i].url);
                            } catch (e) {
                              throw "Could not launch ${urls[index * 2 + i].url}]";
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: MyStyles.pupauTheme(!Get.isDarkMode)
                                      .lilacPressed),
                              color: MyStyles.pupauTheme(!Get.isDarkMode).white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.link, size: isTablet ? 18 : 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      urls[index * 2 + i].url,
                                      style: TextStyle(
                                        fontSize: isTablet ? 15 : 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              if (index * 2 + 1 >= urls.length) const Spacer(),
            ],
          );
        }),
      ),
    );
  }
}
