import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_button.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/modal_top_bar_title.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

/// Lets the user change their message text, then forks from the previous
/// message and sends the new text (same idea as ChatGPT edit).
void showEditMessageModal(PupauMessage message) {
  final PupauChatController chatController = Get.find();
  chatController.editMessageTextController.text = message.query;

  WoltModalSheetPage page(BuildContext modalSheetContext) {
    final bool isTablet = DeviceService.isTablet;
    return WoltModalSheetPage(
      hasTopBarLayer: true,
      isTopBarLayerAlwaysVisible: true,
      topBarTitle: ModalTopBarTitle(title: Strings.editMessageTitle.tr),
      child: _EditMessageBody(
        message: message,
        modalSheetContext: modalSheetContext,
        chatController: chatController,
        isTablet: isTablet,
      ),
    );
  }

  final BuildContext? safeContext = getSafeModalContext();
  if (safeContext == null) {
    return;
  }

  showPupauModalSheet(
    context: safeContext,
    pageListBuilder: (modalSheetContext) {
      return [page(modalSheetContext)];
    },
  );
}

class _EditMessageBody extends StatefulWidget {
  const _EditMessageBody({
    required this.message,
    required this.modalSheetContext,
    required this.chatController,
    required this.isTablet,
  });

  final PupauMessage message;
  final BuildContext modalSheetContext;
  final PupauChatController chatController;
  final bool isTablet;

  @override
  State<_EditMessageBody> createState() => _EditMessageBodyState();
}

class _EditMessageBodyState extends State<_EditMessageBody> {
  @override
  void initState() {
    super.initState();
    widget.chatController.editMessageTextController.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.chatController.editMessageTextController.removeListener(
      _onTextChanged,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool canSend = widget.chatController.editMessageTextController.text
        .trim()
        .isNotEmpty;
    return Obx(() {
      final bool isForking = widget.chatController.isForking.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.editMessageDescription.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: widget.isTablet ? 15 : 13,
                color: MyStyles.getTextTheme(
                  isLightTheme: !Get.isDarkMode,
                ).bodyMedium?.color?.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.chatController.editMessageTextController,
              maxLines: 8,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              spacing: 25,
              children: [
                Expanded(
                  child: CustomButton(
                    text: Strings.undo.tr,
                    isPrimary: false,
                    isEnabled: !isForking,
                    onPressed: () {
                      if (Navigator.canPop(widget.modalSheetContext)) {
                        Navigator.pop(widget.modalSheetContext);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: CustomButton(
                    text: Strings.continue_.tr,
                    isEnabled: canSend && !isForking,
                    isLoading: isForking,
                    onPressed: () async {
                      final String next = widget
                          .chatController
                          .editMessageTextController
                          .text
                          .trim();
                      if (next.isEmpty || isForking) return;
                      await widget.chatController.editUserMessage(
                        widget.message,
                        next,
                      );
                      if (widget.modalSheetContext.mounted) {
                        Navigator.pop(widget.modalSheetContext);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
