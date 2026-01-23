import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/assistant_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';

class ReferenceText extends GetView<ChatController> {
  const ReferenceText({super.key, required this.ref});

  final KbReference ref;

  @override
  Widget build(BuildContext context) {
    KBSettings? kbSettings = controller.assistant.value?.kbSettings;
    bool enableKbDownload = kbSettings?.enableKbDownload ?? false;

    switch (ref.type) {
      case 'FILE':
        return InkWell(
          onTap: enableKbDownload && ref.id != null
              ? () => FileService.downloadKbFile(
                  ref.id!,
                  ref.data,
                  controller.assistant.value?.id ?? "",
                  controller.conversation.value?.id ?? "",
                  controller.isMarketplace)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
            child: Row(children: [
              Icon(
                  enableKbDownload ? Symbols.file_download : Symbols.file_copy),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style:
                        TextStyle(color: Get.theme.textTheme.bodyMedium?.color),
                    children: [
                      TextSpan(text: ref.data),
                      if (ref.pageNumber != null)
                        TextSpan(
                          text: " (${Strings.page.tr}: ${ref.pageNumber!})",
                          style: TextStyle(
                            color: Get.theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.7),
                          ),
                        )
                    ],
                  ),
                ),
              )
            ]),
          ),
        );
      case 'URL':
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
          child: RichTextClickable(
              icon: Symbols.link,
              text: ref.data,
              onPressed: () {
                try {
                  DeviceService.openLink(ref.data);
                } catch (e) {
                  throw "Could not launch $ref]";
                }
              }),
        );
      default:
        return const SizedBox();
    }
  }
}

class RichTextClickable extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String text;

  const RichTextClickable({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                icon,
              ),
            ),
          ),
          TextSpan(
              text: text,
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = onPressed),
        ],
      ),
    );
  }
}
