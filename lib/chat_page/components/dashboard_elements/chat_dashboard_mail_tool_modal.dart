import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/message_mail.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

void showChatDashboardMailToolModal({
  required ToolUseMessage toolUseMessage,
  required bool isAnonymous,
}) {
  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) {
    return;
  }
  WoltModalSheetPage page(BuildContext modalSheetContext) {
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      topBarTitle: ModalTopBarTitle(title: toolUseMessage.getName()),
      isTopBarLayerAlwaysVisible: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: MessageMail(
          toolUseMessage: toolUseMessage,
          isAnonymous: isAnonymous,
        ),
      ),
    );
  }

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (BuildContext modalSheetContext) {
      return <WoltModalSheetPage>[page(modalSheetContext)];
    },
  );
}
