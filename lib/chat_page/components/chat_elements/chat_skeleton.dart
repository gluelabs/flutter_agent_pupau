import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatSkeleton extends StatelessWidget {
  final PupauConfig? config;
  
  const ChatSkeleton({super.key, this.config});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = config?.isAnonymous ?? false;
    bool isTablet = DeviceService.isTablet;
    
    return Theme(
      data: ThemeData(
        brightness: isAnonymous || Get.isDarkMode
            ? Brightness.dark
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isAnonymous
            ? AnonymousThemeColors.background
            : MyStyles.pupauTheme(!Get.isDarkMode).white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          elevation: 1,
          titleSpacing: isTablet ? 20 : 0,
          leadingWidth: 12,
          backgroundColor: isAnonymous
              ? Colors.black
              : MyStyles.pupauTheme(!Get.isDarkMode).white,
          surfaceTintColor: isAnonymous
              ? Colors.black
              : MyStyles.pupauTheme(!Get.isDarkMode).white,
          leading: const SizedBox(width: 16),
          title: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Skeletonizer(
                    enabled: true,
                    effect: StyleService.skeletonEffect(Get.isDarkMode),
                    child: Container(
                      height: isTablet ? 48 : 40,
                      width: isTablet ? 48 : 40,
                      decoration: BoxDecoration(
                        color: isAnonymous
                            ? Colors.white
                            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Skeletonizer(
                    enabled: true,
                    effect: StyleService.skeletonEffect(Get.isDarkMode),
                    child: Container(
                      height: 20,
                      width: 150,
                      decoration: BoxDecoration(
                        color: isAnonymous
                            ? Colors.white
                            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Transform.translate(
              offset: const Offset(-8, 0),
              child: IconButton(
                icon: Icon(Symbols.close),
                iconSize: isTablet ? 26 : 24,
                color: isAnonymous 
                    ? Colors.white 
                    : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                onPressed: () {},
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Expanded(
                  child: Skeletonizer(
                    enabled: true,
                    effect: StyleService.skeletonEffect(Get.isDarkMode),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Skeleton message bubbles
                        _buildSkeletonMessage(isTablet, isAnonymous, true),
                        const SizedBox(height: 16),
                        _buildSkeletonMessage(isTablet, isAnonymous, false),
                        const SizedBox(height: 16),
                        _buildSkeletonMessage(isTablet, isAnonymous, true),
                      ],
                    ),
                  ),
                ),
                // Skeleton input field
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isAnonymous
                        ? Colors.grey[800]
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: isAnonymous
                                ? Colors.grey[700]
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isAnonymous
                              ? Colors.grey[700]
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonMessage(bool isTablet, bool isAnonymous, bool isAssistant) {
    return Row(
      mainAxisAlignment: isAssistant ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAssistant) ...[
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: isAnonymous ? Colors.grey[700] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAnonymous ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAnonymous ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isAnonymous ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isAssistant) ...[
          const SizedBox(width: 12),
          Container(
            width: isTablet ? 48 : 40,
            height: isTablet ? 48 : 40,
            decoration: BoxDecoration(
              color: isAnonymous ? Colors.grey[700] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
