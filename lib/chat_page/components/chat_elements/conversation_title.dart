import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/scroll_button.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ConversationTitle extends GetView<PupauChatController> {
  const ConversationTitle({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final bool isTablet = DeviceService.isTablet;
    return Obx(() {
      String? conversationTitle = controller.conversation.value?.title;
      bool isTempTitle = controller.conversation.value?.hasTempTitle ?? true;
      bool isLoadingTitle = controller.isLoadingTitle.value;
      bool isAnonymous = controller.isAnonymous;
      bool hasUserMessage = controller.messages.length > 1;
      bool scrollButtonVisible = hasUserMessage && !controller.isAtTop.value;
      final Color titleColor = isAnonymous
          ? AnonymousThemeColors.assistantText
          : (MyStyles.getTextTheme(
              isLightTheme: !Get.isDarkMode,
            ).bodyMedium?.color)!;
      // Reserve tall header only while the scroll-to-top chip is visible; it is
      // positioned below the title strip (see [Transform.translate]) and needs
      // overlap space. When hidden, a 102px sliver leaves a large empty gap.
      final double headerExtent = scrollButtonVisible
          ? 102
          : (isTablet ? 62 : 54);
      return SliverPersistentHeader(
        pinned: false,
        floating: true,
        delegate: SliverAppBarDelegate(
          minHeight: headerExtent,
          maxHeight: headerExtent,
          child: Stack(
            children: [
              Container(
                constraints: BoxConstraints(maxHeight: isTablet ? 54 : 46),
                decoration: BoxDecoration(
                  color: isAnonymous
                      ? Colors.black
                      : MyStyles.pupauTheme(!Get.isDarkMode).white,
                  border: Border(
                    bottom: BorderSide(
                      color: isAnonymous
                          ? AnonymousThemeColors.userBubble.withValues(
                              alpha: 0.5,
                            )
                          : MyStyles.pupauTheme(
                              !Get.isDarkMode,
                            ).primary.withValues(alpha: 0.5),
                      width: 0.5,
                    ),
                  ),
                ),
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
                                  color: titleColor,
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w500,
                                ),
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
                                ),
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
                              color: titleColor,
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(-12, 52),
                child: ScrollButton(
                  toBottom: false,
                  isVisible: scrollButtonVisible,
                  onTap: () => controller.scrollToTopChat(withAnimation: true),
                  isAnonymous: isAnonymous,
                ),
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
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) =>
      maxHeight != oldDelegate.maxHeight ||
      minHeight != oldDelegate.minHeight ||
      child != oldDelegate.child;
}
