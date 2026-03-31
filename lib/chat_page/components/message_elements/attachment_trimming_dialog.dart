import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

/// Returns true if [info] has content to show.
bool _hasTrimmingContent(AttachmentTrimmingInfo? info) {
  if (info == null || !info.applied) return false;
  return info.truncatedCount > 0 ||
      info.removedCount > 0 ||
      info.items.isNotEmpty;
}

/// Shows a modal with attachment and/or emergency trimming details (always expanded).
void showAttachmentTrimmingDialog(
  BuildContext context, {
  AttachmentTrimmingInfo? attachmentTrimming,
  AttachmentTrimmingInfo? emergencyTrimming,
  bool isAnonymous = false,
}) {
  final bool hasAttachment = _hasTrimmingContent(attachmentTrimming);
  final bool hasEmergency = _hasTrimmingContent(emergencyTrimming);
  if (!hasAttachment && !hasEmergency) return;

  final bool isTablet = DeviceService.isTablet;
  final List<Widget> sectionChildren = <Widget>[];

  if (hasAttachment && attachmentTrimming != null) {
    sectionChildren.add(
      _TrimmingSection(
        title: Strings.attachmentTrimmingTitle.tr,
        info: attachmentTrimming,
        isTablet: isTablet,
        isAnonymous: isAnonymous,
      ),
    );
  }
  if (hasEmergency && emergencyTrimming != null) {
    if (sectionChildren.isNotEmpty) {
      sectionChildren.add(const SizedBox(height: 20));
    }
    sectionChildren.add(
      _TrimmingSection(
        title: Strings.emergencyTrimmingTitle.tr,
        info: emergencyTrimming,
        isTablet: isTablet,
        isAnonymous: isAnonymous,
      ),
    );
  }

  final String dialogTitle = hasAttachment && hasEmergency
      ? '${Strings.attachmentTrimmingTitle.tr} & ${Strings.emergencyTrimmingTitle.tr}'
      : hasAttachment
          ? Strings.attachmentTrimmingTitle.tr
          : Strings.emergencyTrimmingTitle.tr;

  showDialog<void>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: MyStyles.pupauTheme(!Get.isDarkMode).white,
      title: Row(
        children: [
          Icon(Symbols.warning, size: isTablet ? 24 : 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              dialogTitle,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: isTablet ? 18 : 16,
                color: Get.isDarkMode || isAnonymous
                    ? Colors.white
                    : MyStyles.pupauTheme(!Get.isDarkMode).accent,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sectionChildren,
        ),
      ),
      actions: [
        CustomButton(
          text: Strings.continue_.tr,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}

class _TrimmingSection extends StatelessWidget {
  const _TrimmingSection({
    required this.title,
    required this.info,
    required this.isTablet,
    required this.isAnonymous,
  });

  final String title;
  final AttachmentTrimmingInfo info;
  final bool isTablet;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final int truncated = info.truncatedCount;
    final int removed = info.removedCount;
    final String summaryLine = truncated > 0 && removed > 0
        ? Strings.attachmentTrimmingDetailBoth.tr
            .replaceAll("%1", truncated.toString())
            .replaceAll("%2", removed.toString())
        : truncated > 0
            ? Strings.attachmentTrimmingDetailTruncated.tr
                .replaceAll("%1", truncated.toString())
            : Strings.attachmentTrimmingDetailRemoved.tr
                .replaceAll("%1", removed.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 16 : 14,
            color: Get.isDarkMode || isAnonymous
                ? Colors.white
                : MyStyles.pupauTheme(!Get.isDarkMode).accent,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          summaryLine,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        if (info.items.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...info.items.map((AttachmentTrimmingItem item) {
            final String reasonLabel =
                ConversationService.getAttachmentTrimmingReasonLabel(
              item.reason,
            );
            final bool wasRemoved = item.action == "removed";
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 8),
                    child: Icon(
                      wasRemoved
                          ? Symbols.remove_circle_outline
                          : Symbols.compress,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.filename,
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reasonLabel,
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Strings.attachmentTrimmingTokensDetail.tr
                              .replaceAll(
                                "%1",
                                item.estimatedTokensBefore.toString(),
                              )
                              .replaceAll(
                                "%2",
                                item.estimatedTokensAfter.toString(),
                              )
                              .replaceAll(
                                "%3",
                                item.estimatedTokensSaved.toString(),
                              ),
                          style: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
