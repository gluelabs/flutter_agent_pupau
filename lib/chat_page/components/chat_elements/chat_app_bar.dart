import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_info_modal.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/assistant_avatar.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/marketplace_icon.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatAppBar extends GetView<ChatController>
    implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.isAnonymous,
    this.onBackPressed,
    required this.widgetMode,
  });

  final bool isAnonymous;
  final VoidCallback? onBackPressed;
  final WidgetMode widgetMode;

  @override
  Widget build(BuildContext context) {
    Assistant? assistant = controller.assistant.value;
    bool isMarketplace = assistant?.type == AssistantType.marketplace;
    bool isTablet = DeviceService.isTablet;
    bool hasCloseButton =
        controller.widgetMode == WidgetMode.floating ||
        (controller.widgetMode == WidgetMode.sized &&
            (controller.pupauConfig?.sizedConfig?.hasCloseButton ?? true));
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      elevation: 1,
      titleSpacing: isTablet ? 20 : 0,
      leadingWidth: hasCloseButton ? 12 : 45,
      actionsIconTheme: IconThemeData(
        color: isAnonymous
            ? Colors.white
            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
        size: isTablet ? 26 : 24,
      ),
      backgroundColor: isAnonymous
          ? Colors.black
          : MyStyles.pupauTheme(!Get.isDarkMode).white,
      surfaceTintColor: isAnonymous
          ? Colors.black
          : MyStyles.pupauTheme(!Get.isDarkMode).white,
      leading: hasCloseButton
          ? const SizedBox(width: 16)
          : Padding(
              padding: const EdgeInsets.only(left: 6),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Symbols.arrow_back_ios,
                  color: isAnonymous
                      ? Colors.white
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                ),
              ),
            ),
      title: Padding(
        padding: EdgeInsets.only(top: widgetMode != WidgetMode.full ? 16 : 0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Skeletonizer(
                enabled: assistant == null,
                effect: StyleService.skeletonEffect(Get.isDarkMode),
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: assistant == null
                      ? null
                      : () {
                          controller.keyboardFocusNode.unfocus();
                          showAssistantInfoModal(assistant);
                        },
                  child: Container(
                    height: isTablet ? 48 : 40,
                    width: isTablet ? 48 : 40,
                    decoration: BoxDecoration(
                      color: isAnonymous
                          ? Colors.white
                          : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAnonymous
                            ? Colors.white
                            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                        width: 1.5,
                      ),
                    ),
                    child: assistant == null
                        ? SizedBox(
                            height: isTablet ? 48 : 40,
                            width: isTablet ? 48 : 40,
                          )
                        : AssistantAvatar(
                            assistantId: assistant.id,
                            imageUuid: assistant.imageUuid,
                            radius: isTablet ? 24 : 20,
                            isMarketplaceUrl: isMarketplace,
                            format: ImageFormat.low,
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Skeletonizer(
                enabled: assistant == null,
                child: InkWell(
                  onTap: assistant == null
                      ? null
                      : () => showAssistantInfoModal(assistant),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          assistant?.name ?? "Assistant Name ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 15,
                            color: isAnonymous
                                ? Colors.white
                                : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                          ),
                        ),
                      ),
                      if (isMarketplace)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: MarketplaceIcon(
                            color: MyStyles.pupauTheme(
                              !Get.isDarkMode,
                            ).darkBlue,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: hasCloseButton
          ? [
              Transform.translate(
                offset: Offset(-8, 0),
                child: IconButton(
                  icon: Icon(Symbols.close),
                  iconSize: isTablet ? 26 : 24,
                  color: isAnonymous
                      ? Colors.white
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
                  tooltip: Strings.back.tr,
                  onPressed: () => onBackPressed?.call(),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(DeviceService.isTablet ? 65 : 55);
}
