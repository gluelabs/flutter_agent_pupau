import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/tool_use_info.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_s_m_t_p_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

class SMTPToolContent extends StatelessWidget {
  const SMTPToolContent({
    super.key,
    required this.smtpData
  });

  final ToolUseSMTPData? smtpData;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    if (smtpData == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        children: [
          ToolUseInfo(
            infoKey: Strings.subject.tr,
            infoValue: smtpData?.subject ?? "",
            isAnonymous: false,
            forceExpanded: true,
          ),
          if (smtpData!.to != null)
            ToolUseInfo(
              infoKey: Strings.toEmail.tr.replaceAll("£", ""),
              infoValue: smtpData?.to ?? "",
              isAnonymous: false,
              forceExpanded: true,
            ),
          if (smtpData!.cc != null)
            ToolUseInfo(
              infoKey: Strings.ccEmail.tr,
              infoValue: smtpData?.cc ?? "",
              isAnonymous: false,
              forceExpanded: true,
            ),
          if (smtpData!.bcc != null)
            ToolUseInfo(
              infoKey: Strings.bccEmail.tr,
              infoValue: smtpData?.bcc ?? "",
              isAnonymous: false,
              forceExpanded: true,
            ),
          ToolUseInfo(
            infoKey: Strings.body.tr,
            infoValue: smtpData?.body ?? "",
            isAnonymous: false,
            forceExpanded: true,
          ),
          if (isTablet) const SizedBox(height: 24),
        ],
      ),
    );
  }
}
