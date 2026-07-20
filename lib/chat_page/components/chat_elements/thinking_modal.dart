import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selection_field.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selection_item.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_switch.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showThinkingModal() {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    final bool isTablet = DeviceService.isTablet;
    final PupauChatController controller = Get.find();
    final List<String> efforts = controller.supportedThinkingEfforts();

    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: "Thinking Effort"),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 18, right: 18, bottom: 8),
        child: Obx(() {
          final bool enabled = controller.thinkingEnabled.value;
          final String currentEffort = controller.thinkingEffort.value.trim();
          final String? selectedEffort = efforts.contains(currentEffort)
              ? currentEffort
              : null;
          final List<Widget> effortItems = efforts
              .map(
                (String e) => CustomSelectionItem(
                  value: e,
                  isSelected: selectedEffort == e,
                  onTap: () {
                    Get.back();
                    controller.setThinkingEffort(e);
                  },
                ),
              )
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!controller.isThinkingSupported())
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    Strings.thinkingNotSupported.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                )
              else ...[
                InkWell(
                  onTap: () => controller.setThinkingEnabled(!enabled),
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          Strings.enableThinking.tr,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w600,
                            color: MyStyles.getTextTheme(
                              isLightTheme: !Get.isDarkMode,
                            ).bodyMedium?.color,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 0.7,
                        child: CustomSwitch(
                          isActive: enabled,
                          onChanged: (bool v) =>
                              controller.setThinkingEnabled(v),
                        ),
                      ),
                    ],
                  ),
                ),
                if (efforts.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: enabled ? 1 : 0.5,
                    child: CustomSelectionField(
                      label: Strings.effort.tr,
                      value: selectedEffort ?? Strings.notSelected.tr,
                      modalTitle: Strings.effort.tr,
                      modalItems: effortItems,
                      readOnly: !enabled,
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }

  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (modalSheetContext) => [page(modalSheetContext)],
  );
}
