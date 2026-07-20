import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/active_skill_card.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/close_icon.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_info_box.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/skill_loaded_info.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showActiveSkillsModal() {
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    final bool isTablet = DeviceService.isTablet;
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: Builder(
        builder: (context) {
          final PupauThemeData pupauTheme =
              Theme.of(context).extension<PupauThemeData>()!;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            Strings.activeSkills.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.w600,
                              color: pupauTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Symbols.info,
                          color: pupauTheme.primary,
                          size: isTablet ? 22 : 20,
                        ),
                        tooltip: Strings.info.tr,
                        onPressed: () => showInfoBox(
                          Strings.activeSkills.tr,
                          Strings.activeSkillsInfo.tr,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: CloseIcon(),
              ),
            ],
          );
        },
      ),
      isTopBarLayerAlwaysVisible: true,
      child: Obx(() {
        final PupauChatController chat = Get.find<PupauChatController>();
        final List<SkillLoadedInfo> skills =
            List<SkillLoadedInfo>.from(chat.conversationActiveSkills.values)
              ..sort(
                (SkillLoadedInfo a, SkillLoadedInfo b) =>
                    a.name.toLowerCase().compareTo(b.name.toLowerCase()),
              );
        return SingleChildScrollView(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
          child: ListView.builder(
            itemCount: skills.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) =>
                ActiveSkillCard(skill: skills[index]),
          ),
        );
      }),
    );
  }

  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (modalSheetContext) {
      return [page(modalSheetContext)];
    },
  );
}
