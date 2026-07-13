import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_selectable_text.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_mail_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/style_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';

class MessageMail extends StatelessWidget {
  const MessageMail({
    super.key,
    required this.toolUseMessage,
    required this.isAnonymous,
  });

  final ToolUseMessage? toolUseMessage;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final ToolUseMailData? data = toolUseMessage?.mailData;
    final bool isTablet = DeviceService.isTablet;

    final TextStyle labelStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      fontWeight: FontWeight.w600,
      color: Get.isDarkMode || isAnonymous ? Colors.white : Colors.black87,
    );
    final TextStyle secondaryTextStyle = TextStyle(
      fontSize: isTablet ? 15 : 14,
      color: Get.isDarkMode || isAnonymous ? Colors.white70 : Colors.black87,
    );

    if (data == null) {
      final String fallbackBody =
          toolUseMessage?.nativeToolData?['message']?.toString() ?? '';
      return fallbackBody.trim().isEmpty
          ? const SizedBox.shrink()
          : CustomSelectableText(text: fallbackBody, isAnonymous: isAnonymous);
    }

    final String bodyPreview = data.hasHtmlBody
        ? data.bodyPlaintextPreview
        : data.body.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.to.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.toEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.to.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.cc.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.ccEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.cc.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.bcc.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.bccEmail.tr}: ', style: labelStyle),
              Expanded(child: Text(data.bcc.trim(), style: secondaryTextStyle)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        if (data.subject.trim().isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Strings.subject.tr}: ', style: labelStyle),
              Expanded(
                child: Text(data.subject.trim(), style: secondaryTextStyle),
              ),
            ],
          ),
        ],
        if (bodyPreview.trim().isNotEmpty) ...[
          Theme(
            data: StyleService.expansionTileThemeData(context, isAnonymous),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              initiallyExpanded: true,
              title: Text(Strings.body.tr, style: labelStyle),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: data.hasHtmlBody
                      ? HtmlWidget(
                          data.body.trim(),
                          textStyle: secondaryTextStyle,
                          onTapUrl: (url) {
                            DeviceService.openLink(url);
                            return true;
                          },
                        )
                      : CustomSelectableText(
                          text: data.body.trim(),
                          isAnonymous: isAnonymous,
                          openLinks: true,
                        ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
