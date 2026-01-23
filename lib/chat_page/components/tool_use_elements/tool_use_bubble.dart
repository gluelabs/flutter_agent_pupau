import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_image_generation_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/tool_use_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/basic_tool_use_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/image_generation_tool_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/smtp_info_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_message_content.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/organic_info_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_images_modal.dart';
import 'package:flutter_agent_pupau/chat_page/components/web_elements/web_search_news_modal.dart';

class ToolUseBubble extends GetView<ChatController> {
  const ToolUseBubble({
    super.key,
    required this.message,
  });

  final ToolUseMessage message;

  void tapToolUse() {
    if (message.type == ToolUseType.nativeToolsWebSearch) {
      List<OrganicInfo> organicInfo = message.webSearchData?.organicInfo ?? [];
      if (organicInfo.isNotEmpty) showOrganicInfoModal(organicInfo);
      List<WebSearchImage> images = message.webSearchData?.images ?? [];
      if (images.isNotEmpty) showWebSearchImagesModal(images);
      List<WebSearchNews> news = message.webSearchData?.news ?? [];
      if (news.isNotEmpty) showWebSearchNewsModal(news);
    } else if (message.type == ToolUseType.nativeToolsSMTP) {
      showSMTPInfoModal(message);
    } else if (ToolUseService.isModalToolUse(message.type)) {
      showBasicToolUseModal(message, controller.isAnonymous);
    } else if (message.type == ToolUseType.nativeToolsImageGeneration) {
      List<GeneratedImageData> images =
          message.imageGenerationData?.images ?? [];
      images.isNotEmpty
          ? showImageGenerationToolModal(images)
          : controller.toggleToolUseExpanded(message.id);
    } else if (message.type == ToolUseType.nativeToolsWebReader &&
        message.webReaderData?.url != null &&
        message.webReaderData?.url != "") {
      DeviceService.openLink(message.webReaderData?.url ?? "");
    } else {
      controller.toggleToolUseExpanded(message.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isInitiallyExpanded =
        ToolUseService.isInitiallyExpandedTool(message.type);
    return Obx(() {
      bool isAnonymous = controller.isAnonymous;
      bool isExpanded = isInitiallyExpanded
          ? !controller.isToolUseExpanded(message.id)
          : controller.isToolUseExpanded(message.id);
      IconData? toolUseIcon =
          ToolUseService.getToolUseIcon(message.type);
      bool showTool = message.showTool;
      IconData? toolSuffixIcon =
          ToolUseMessage.getToolUseSuffixIcon(message.type);
      bool isChevronIcon = toolSuffixIcon == Symbols.chevron_forward;
      bool isUserToggled =
          // ignore: invalid_use_of_protected_member
          controller.userToggledToolUseMessages.value.contains(message.id);
      return Visibility(
        visible: showTool,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Theme(
              data: Theme.of(context).copyWith(
                  splashFactory: NoSplash.splashFactory,
                  focusColor: Colors.transparent),
              child: InkWell(
                onTap: tapToolUse,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isAnonymous
                          ? Colors.white70
                          : MyStyles.pupauTheme(!Get.isDarkMode).lilacPressed,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ToolUseAvatar(
                            toolUseIcon: toolUseIcon,
                            isAnonymous: isAnonymous,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      message.getName(),
                                      maxLines: isExpanded ? 10 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 16 : 14,
                                        color: Get.isDarkMode || isAnonymous
                                            ? Colors.white
                                            : MyStyles.pupauTheme(
                                                    !Get.isDarkMode)
                                                .accent,
                                      ),
                                    ),
                                  ),
                                  if (message.browserUseData
                                          ?.isLoadingPlaceholder ??
                                      false)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: SizedBox(
                                        width: 9,
                                        height: 9,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Get.isDarkMode || isAnonymous
                                              ? Colors.white
                                              : MyStyles.pupauTheme(
                                                      !Get.isDarkMode)
                                                  .accent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                           Padding(
                             padding: const EdgeInsets.only(top: 2),
                             child: AnimatedRotation(
                               key: ValueKey('${message.id}_rotation'),
                               turns: isChevronIcon
                                   ? (isExpanded ? 0.75 : 0.25)
                                   : 0,
                               duration: isUserToggled 
                                   ? const Duration(milliseconds: 200) 
                                   : Duration.zero,
                               curve: Curves.easeInOut,
                               child: Icon(
                                 ToolUseMessage.getToolUseSuffixIcon(
                                     message.type),
                                 color: Get.isDarkMode || isAnonymous
                                     ? Colors.white.withValues(alpha: 0.7)
                                     : MyStyles.pupauTheme(!Get.isDarkMode)
                                         .accent
                                         .withValues(alpha: 0.7),
                                 size: 24,
                               ),
                             ),
                           ),
                        ],
                      ),
                       AnimatedSize(
                         key: ValueKey('${message.id}_size'),
                         duration: isUserToggled 
                             ? const Duration(milliseconds: 200) 
                             : Duration.zero,
                         curve: Curves.easeInOut,
                         child: isExpanded
                             ? Padding(
                                 padding: const EdgeInsets.only(top: 8),
                                 child: ToolUseMessageContent(
                                   toolUseMessage: message,
                                   isAnonymous: isAnonymous,
                                 ),
                               )
                             : const SizedBox.shrink(),
                       ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
