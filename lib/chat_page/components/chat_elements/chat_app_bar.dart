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

class ChatAppBar extends GetView<PupauChatController>
    implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.isAnonymous,
    this.onBackPressed,
    this.config,
  });

  final bool isAnonymous;
  final VoidCallback? onBackPressed;
  final PupauConfig? config;

  @override
  Widget build(BuildContext context) {
    // Prefer static config (passed from widget) while controller is still
    // initializing, then fall back to controller config once available.
    AppBarConfig? appBarConfig =
        config?.appBarConfig ?? controller.pupauConfig?.appBarConfig;
    bool showAppBar = appBarConfig?.showAppBar ?? true;

    if (!showAppBar) return const SafeArea(child: SizedBox.shrink());

    bool isTablet = DeviceService.isTablet;
    return Obx(() {
      Assistant? assistant = controller.assistant.value;
      bool isMarketplace = assistant?.type == AssistantType.marketplace;
      WidgetMode widgetMode = config?.widgetMode ?? controller.widgetMode;
      // Determine close button defaults based on widget mode
      CloseStyle defaultCloseStyle = widgetMode == WidgetMode.full
          ? CloseStyle.arrow
          : CloseStyle.cross;
      CloseButtonPosition defaultClosePosition = widgetMode == WidgetMode.full
          ? CloseButtonPosition.left
          : CloseButtonPosition.right;

      // Get close button configuration (use defaults if not specified)
      CloseStyle? explicitCloseStyle = appBarConfig?.closeStyle;
      CloseStyle closeStyle = explicitCloseStyle ?? defaultCloseStyle;
      CloseButtonPosition closePosition =
          appBarConfig?.closeButtonPosition ?? defaultClosePosition;

      // Determine if close button should be shown
      bool shouldShowCloseButton = closeStyle != CloseStyle.none;

      // Build close button widget
      Widget? closeButton;
      if (shouldShowCloseButton) {
        IconData closeIcon = closeStyle == CloseStyle.arrow
            ? Symbols.arrow_back_ios
            : Symbols.close;
        Widget button = IconButton(
          icon: Icon(closeIcon),
          iconSize: isTablet ? 26 : 24,
          color: isAnonymous
              ? Colors.white
              : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
          tooltip: Strings.back.tr,
          onPressed: () => widgetMode == WidgetMode.full
              ? Navigator.of(context).pop()
              : onBackPressed?.call(),
        );

        // Apply transform offset for cross icon on the right
        if (closeStyle == CloseStyle.cross &&
            closePosition == CloseButtonPosition.right) {
          closeButton = Transform.translate(
            offset: Offset(-8, 0),
            child: button,
          );
        } else {
          closeButton = button;
        }
      }

      // Build actions list: custom actions + close button (if on right)
      List<Widget>? actionsList;
      List<Widget>? customActions = appBarConfig?.actions;
      
      if (customActions != null) {
        // Wrap actions to use controller's scaffoldContext which has Scaffold access
        customActions = customActions.map((action) {
          if (action is IconButton && action.onPressed != null) {
            final Function? originalOnPressed = action.onPressed;
            return IconButton(
              icon: action.icon,
              iconSize: action.iconSize,
              color: action.color,
              disabledColor: action.disabledColor,
              focusColor: action.focusColor,
              hoverColor: action.hoverColor,
              highlightColor: action.highlightColor,
              splashColor: action.splashColor,
              tooltip: action.tooltip,
              onPressed: () {
                // Try original callback first
                try {
                  originalOnPressed?.call();
                } catch (e) {
                  // If Scaffold.of() fails, try to open drawer using scaffoldKey or scaffoldContext
                  final errorStr = e.toString();
                  if (errorStr.contains('Scaffold') && 
                      errorStr.contains('does not contain')) {
                    // First try scaffoldKey (most reliable)
                    final scaffoldKey = controller.pupauConfig?.drawerConfig?.scaffoldKey;
                    if (scaffoldKey?.currentState != null) {
                      scaffoldKey!.currentState!.openEndDrawer();
                      return;
                    }
                    // Fallback to scaffoldContext
                    final scaffoldContext = controller.scaffoldContext;
                    if (scaffoldContext != null) {
                      final scaffold = Scaffold.maybeOf(scaffoldContext);
                      scaffold?.openEndDrawer();
                    }
                  } else {
                    rethrow;
                  }
                }
              },
              autofocus: action.autofocus,
              isSelected: action.isSelected,
              selectedIcon: action.selectedIcon,
              mouseCursor: action.mouseCursor,
              visualDensity: action.visualDensity,
              padding: action.padding,
              constraints: action.constraints,
              style: action.style,
              alignment: action.alignment,
              splashRadius: action.splashRadius,
            );
          }
          return action;
        }).toList();
      }
      
      if (closePosition == CloseButtonPosition.right && closeButton != null) {
        actionsList = [
          if (customActions != null) ...customActions,
          closeButton,
        ];
      } else if (customActions != null) {
        actionsList = customActions;
      }

      return AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 1,
        titleSpacing: 0,
        leadingWidth:
            closeButton != null && closePosition == CloseButtonPosition.left
            ? 48
            : 24,
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
        leading:
            closePosition == CloseButtonPosition.left && closeButton != null
            ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: closeButton,
              )
            : const SizedBox(),
        title: Row(
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
        actions: actionsList,
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(DeviceService.isTablet ? 65 : 55);
}
