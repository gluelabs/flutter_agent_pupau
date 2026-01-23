import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/related_search_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class RelatedSearchesList extends GetView<ChatController> {
  const RelatedSearchesList({
    super.key,
    required this.relatedSearches,
  });

  final List<String> relatedSearches;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isAnonymous = controller.isAnonymous;
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: EdgeInsets.symmetric(horizontal: 10),
          expansionAnimationStyle: AnimationStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
          ),
          onExpansionChanged: (expanded) async {
            if (expanded) {
              await Future.delayed(const Duration(milliseconds: 100));
              controller.scrollToBottomChat(withAnimation: true);
            }
          },
          leading: Icon(
            Symbols.help,
            size: isTablet ? 26 : 24,
            color: isAnonymous
                ? AnonymousThemeColors.assistantText
                : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          ),
          title: Text(
            Strings.relatedSearches.tr,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w500,
              color: isAnonymous
                  ? AnonymousThemeColors.assistantText
                  : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              child: Wrap(
                spacing: 4,
                runSpacing: 8,
                children: [
                  for (String search in relatedSearches)
                    RelatedSearchButton(prompt: search),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
