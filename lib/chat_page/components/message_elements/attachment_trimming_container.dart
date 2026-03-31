import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/theme_extensions/pupau_theme_data.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class AttachmentTrimmingContainer extends StatefulWidget {
  const AttachmentTrimmingContainer({
    super.key,
    required this.attachmentTrimming,
    this.isAnonymous = false,
  });

  final AttachmentTrimmingInfo attachmentTrimming;
  final bool isAnonymous;

  @override
  State<AttachmentTrimmingContainer> createState() =>
      _AttachmentTrimmingContainerState();
}

class _AttachmentTrimmingContainerState
    extends State<AttachmentTrimmingContainer> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final bool hasCounts = widget.attachmentTrimming.truncatedCount > 0 ||
        widget.attachmentTrimming.removedCount > 0;
    if (!widget.attachmentTrimming.applied ||
        (!hasCounts && widget.attachmentTrimming.items.isEmpty)) {
      return const SizedBox();
    }

    final bool isAnonymous = widget.isAnonymous;
    final bool isTablet = DeviceService.isTablet;
    final PupauThemeData theme = MyStyles.pupauTheme(!Get.isDarkMode);
    final int truncated = widget.attachmentTrimming.truncatedCount;
    final int removed = widget.attachmentTrimming.removedCount;

    final String summaryLine = truncated > 0 && removed > 0
        ? Strings.attachmentTrimmingDetailBoth.tr
              .replaceAll("%1", truncated.toString())
              .replaceAll("%2", removed.toString())
        : truncated > 0
        ? Strings.attachmentTrimmingDetailTruncated.tr.replaceAll(
            "%1",
            truncated.toString(),
          )
        : Strings.attachmentTrimmingDetailRemoved.tr.replaceAll(
            "%1",
            removed.toString(),
          );

    final Color borderColor = isAnonymous ? Colors.white70 : theme.lilacPressed;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          child: Theme(
            data: Theme.of(context).copyWith(
              splashFactory: NoSplash.splashFactory,
              focusColor: Colors.transparent,
            ),
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                width: isTablet ? null : DeviceService.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Symbols.content_cut, size: isTablet ? 20 : 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                Strings.attachmentTrimmingTitle.tr,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 16 : 14,
                                  color: Get.isDarkMode || isAnonymous
                                      ? Colors.white
                                      : MyStyles.pupauTheme(
                                          !Get.isDarkMode,
                                        ).accent,
                                ),
                              ),
                              Text(
                                summaryLine,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: isTablet ? 14 : 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Symbols.expand_more,
                            color: Get.isDarkMode || isAnonymous
                                ? Colors.white
                                : MyStyles.pupauTheme(!Get.isDarkMode).accent,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      child:
                          _expanded &&
                              widget.attachmentTrimming.items.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ...widget.attachmentTrimming.items.map((
                                    AttachmentTrimmingItem item,
                                  ) {
                                    final String reasonLabel =
                                        ConversationService.getAttachmentTrimmingReasonLabel(
                                          item.reason,
                                        );
                                    final bool wasRemoved =
                                        item.action == "removed";
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                              right: 6,
                                            ),
                                            child: Icon(
                                              wasRemoved
                                                  ? Symbols
                                                        .remove_circle_outline
                                                  : Symbols.compress,
                                              size: 16,
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.filename,
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 16
                                                        : 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  reasonLabel,
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 14
                                                        : 12,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  Strings
                                                      .attachmentTrimmingTokensDetail
                                                      .tr
                                                      .replaceAll(
                                                        "%1",
                                                        item.estimatedTokensBefore
                                                            .toString(),
                                                      )
                                                      .replaceAll(
                                                        "%2",
                                                        item.estimatedTokensAfter
                                                            .toString(),
                                                      )
                                                      .replaceAll(
                                                        "%3",
                                                        item.estimatedTokensSaved
                                                            .toString(),
                                                      ),
                                                  style: TextStyle(
                                                    fontSize: isTablet
                                                        ? 12
                                                        : 11,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
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
  }
}
