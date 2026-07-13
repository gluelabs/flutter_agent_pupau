import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/memory_always_row.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/memory_reference_row.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/memory_section_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/models/memory_always_model.dart';
import 'package:flutter_agent_pupau/models/memory_reference_model.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showMemoryReferencesModal({
  required List<MemoryAlways> alwaysMemories,
  required List<MemoryReference> references,
}) {
  final bool hasAlways = alwaysMemories.isNotEmpty;
  final bool hasRefs = references.isNotEmpty;
  if (!hasAlways && !hasRefs) return;

  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      surfaceTintColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: Strings.memoriesUsed.tr),
      isTopBarLayerAlwaysVisible: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAlways) ...[
                MemorySectionTitle(title: Strings.memoriesAlwaysActive.tr),
                const SizedBox(height: 12),
                ...alwaysMemories.map((MemoryAlways m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: MemoryAlwaysRow(memory: m),
                  );
                }),
                const SizedBox(height: 12),
              ],
              if (hasRefs) ...[
                MemorySectionTitle(
                  title: Strings.memoriesRelevantForThisResponse.tr,
                ),
                const SizedBox(height: 12),
                ...references.map((MemoryReference m) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MemoryReferenceRow(memory: m),
                  );
                }),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) return;

  WoltModalSheet.show(
    context: safeContext,
    pageListBuilder: (modalSheetContext) => [page(modalSheetContext)],
  );
}
