import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/scroll_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ConversationTitle extends GetView<ChatController> {
  const ConversationTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      String? conversationTitle = controller.conversation.value?.title;
      bool isTempTitle =
          controller.conversation.value?.hasTempTitle ?? true;
      bool isLoadingTitle = controller.isLoadingTitle.value;
      bool isAnonymous = controller.isAnonymous;
      bool hasUserMessage = controller.messages.length > 1;
      bool scrollButtonVisible = hasUserMessage && !controller.isAtTop.value;
      return SliverPersistentHeader(
        pinned: false,
        floating: true,
        delegate: SliverAppBarDelegate(
          minHeight: isTablet ? 102 : 102,
          maxHeight: isTablet ? 102 : 102,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: isTablet ? 54 : 46,
                ),
                decoration: BoxDecoration(
                    color: isAnonymous
                        ? Colors.black
                        : MyStyles.pupauTheme(!Get.isDarkMode).white,
                    border: Border(
                        bottom: BorderSide(
                            color: isAnonymous
                                ? AnonymousThemeColors.userBubble
                                : MyStyles.pupauTheme(!Get.isDarkMode).lilac,
                            width: 4))),
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: isTempTitle || conversationTitle == null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isAnonymous
                                  ? Strings.anonymousConversation.tr
                                  : Strings.newConversation.tr,
                              style: TextStyle(
                                  color: isAnonymous
                                      ? Colors.white
                                      : MyStyles.pupauTheme(
                                              !Get.isDarkMode || isAnonymous)
                                          .darkBlue,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            if (isLoadingTitle && hasUserMessage)
                              const Padding(
                                padding: EdgeInsets.only(left: 16),
                                child: SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                          ],
                        )
                      : Text(
                          isAnonymous
                              ? Strings.anonymousConversation.tr
                              : conversationTitle,
                          maxLines: 2,
                          softWrap: true,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              color: isAnonymous
                                  ? Colors.white
                                  : MyStyles.pupauTheme(
                                          !Get.isDarkMode || isAnonymous)
                                      .darkBlue,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w500),
                        ),
                )),
              ),
              Transform.translate(
                offset: const Offset(-12, 52),
                child: ScrollButton(
                    toBottom: false,
                    isVisible: scrollButtonVisible,
                    onTap: () => controller.scrollToTopChat(withAnimation: true),
                    isAnonymous: isAnonymous),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
          BuildContext context, double shrinkOffset, bool overlapsContent) =>
      SizedBox.expand(child: child);

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight ||
      minHeight != oldDelegate.minHeight ||
      child != oldDelegate.child;
}
