import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_app_bar.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class ChatSkeleton extends StatelessWidget {
  final PupauConfig? config;
  const ChatSkeleton({super.key, this.config});

  @override
  Widget build(BuildContext context) {
    bool isAnonymous = config?.isAnonymous ?? false;

    return Theme(
      data: ThemeData(
        brightness: isAnonymous || Get.isDarkMode
            ? Brightness.dark
            : Brightness.light,
      ),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: MediaQuery.of(context).padding.copyWith(
            top: config?.widgetMode == WidgetMode.full ? 48 : 20,
          ),
        ),
        child: Scaffold(
          backgroundColor: isAnonymous
              ? AnonymousThemeColors.background
              : MyStyles.pupauTheme(!Get.isDarkMode).white,
          appBar: ChatAppBar(
            isAnonymous: isAnonymous,
            config: config,
          ),
          body: SafeArea(
            top: false,
            child: const Column(children: [Expanded(child: SizedBox())]),
          ),
        ),
      ),
    );
  }
}
