import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

import 'my_menu_item.dart';

bool _hasTrimmingContent(AttachmentTrimmingInfo? info) {
  if (info == null || !info.applied) return false;
  return info.truncatedCount > 0 ||
      info.removedCount > 0 ||
      info.items.isNotEmpty;
}

ContextMenu getContextMenu(
  bool isFromAssistant,
  Reaction currentReaction,
  bool hideInputBox, {
  PupauMessage? message,
}) {
  PupauChatController controller = Get.find();
  bool showForkConversationIcon = controller.pupauConfig?.bearerToken != null;
  final bool canEditUserMessage = !isFromAssistant &&
      showForkConversationIcon &&
      (message?.isAudioInput != true);
  final bool hasTrimmingContent = isFromAssistant &&
      (_hasTrimmingContent(message?.attachmentTrimming) ||
          _hasTrimmingContent(message?.emergencyTrimming));

  final List<ContextMenuEntry> messageMenuEntries = <ContextMenuEntry>[
    if (isFromAssistant)
      MyMenuItem(
        label: Strings.like.tr,
        icon: currentReaction == Reaction.like
            ? Icons.thumb_up
            : Symbols.thumb_up,
        value: 0,
      ),
    if (isFromAssistant)
      MyMenuItem(
        label: Strings.dislike.tr,
        icon: currentReaction == Reaction.dislike
            ? Icons.thumb_down
            : Symbols.thumb_down,
        value: 1,
      ),
    if (isFromAssistant) const MenuDivider(),
    MyMenuItem(label: Strings.copy.tr, icon: Symbols.content_copy, value: 2),
    if (!isFromAssistant && !hideInputBox)
      MyMenuItem(label: Strings.use.tr, icon: Symbols.send, value: 3),
    if (canEditUserMessage)
      MyMenuItem(label: Strings.edit.tr, icon: Symbols.edit, value: 8),
    if (isFromAssistant)
      MyMenuItem(label: Strings.read.tr, icon: Symbols.volume_up, value: 4),
    if (isFromAssistant) const MenuDivider(),
    if (isFromAssistant && showForkConversationIcon)
      MyMenuItem(
        label: Strings.fork.tr,
        icon: Symbols.fork_left,
        flipIcon: true,
        value: 5,
      ),
    if (isFromAssistant && hasTrimmingContent)
      MyMenuItem(
        label: Strings.attachmentTrimmingTitle.tr,
        icon: Symbols.warning,
        value: 7,
      ),
    if (isFromAssistant)
      MyMenuItem(
        label: Strings.report.tr,
        icon: Symbols.error,
        value: 6,
      ),
  ];

  final ContextMenu contextMenu = ContextMenu(
    entries: messageMenuEntries,
    padding: const EdgeInsets.all(8.0),
  );
  return contextMenu;
}
