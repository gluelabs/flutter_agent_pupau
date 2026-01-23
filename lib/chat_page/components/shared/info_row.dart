import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:get/get.dart';

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.title,
    required this.info,
    this.topPadding = 15,
    this.latPadding = 20,
    this.isCopyable = false,
  });

  final String title;
  final String info;
  final double topPadding;
  final double latPadding;
  final bool isCopyable;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return info.trim() != ""
        ? Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: latPadding,
                    left: latPadding,
                    top: topPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 15,
                          fontWeight: FontWeight.w500,
                          color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                        ),
                      ),
                      Text(
                        info,
                        style: TextStyle(fontSize: isTablet ? 18 : 14),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCopyable)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: info));
                      showFeedbackSnackbar(
                        Strings.copiedClipboard.tr,
                        Symbols.content_copy,
                        isInfo: true,
                      );
                    },
                    tooltip: Strings.copy.tr,
                    icon: Icon(
                      Symbols.content_copy,
                      color: MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                      size: isTablet ? 26 : 24,
                    ),
                  ),
                ),
            ],
          )
        : const SizedBox();
  }
}
