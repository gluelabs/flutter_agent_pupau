import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/conversation_starters_list.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/tag_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class EmptyConversationView extends GetView<PupauChatController> {
  const EmptyConversationView({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return Obx(() {
      final bool isAnonymous = controller.isAnonymous;
      final Assistant? assistant = controller.assistant.value;
      final String assistantId = assistant?.id ?? controller.assistantId;
      final String assistantName = assistant?.name.trim() ?? "";
      final String assistantImageUuid = assistant?.imageUuid ?? "";
      final String welcome = TagService.addUserNameTag(
        controller.effectiveWelcomeMessage,
      ).trim(); 
      final Color primaryTextColor = isAnonymous
          ? AnonymousThemeColors.assistantText
          : MyStyles.pupauTheme(!Get.isDarkMode).black;
      final Color secondaryTextColor = isAnonymous
          ? AnonymousThemeColors.assistantText.withValues(alpha: 0.75)
          : MyStyles.pupauTheme(!Get.isDarkMode).black.withValues(alpha: 0.7);

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AssistantAvatar(
                  assistantId: assistantId,
                  imageUuid: assistantImageUuid,
                  radius: 26,
                  format: ImageFormat.low,
                ),
                const SizedBox(height: 12),
                if (assistantName.isNotEmpty)
                  Text(
                    assistantName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: primaryTextColor,
                    ),
                  ),
                if (assistantName.isNotEmpty) const SizedBox(height: 10),
      
               if (welcome.isNotEmpty)
                  Text(
                    welcome,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.35,
                      color: secondaryTextColor,
                    ),
                  ),
                const SizedBox(height: 26),
                if (controller.conversationStarters.isNotEmpty) ...<Widget>[
                  Text(
                    Strings.promptSuggestionsForYou.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const ConversationStartersList(),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

