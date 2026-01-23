import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_message_model.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_knowledge_base_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MessageKnowledgeBase extends StatelessWidget {
  const MessageKnowledgeBase({
    super.key,
    required this.toolUseMessage,
  });

  final ToolUseMessage? toolUseMessage;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    ToolUseKnowledgeBaseData? ragData = toolUseMessage?.knowledgeBaseData;
    bool noData = ragData?.kbId == null || ragData?.kbId == "";
    List<Map<String, String>> kbInfo = [
      {
        "key": "KB ID",
        "value": ragData?.kbId ?? "",
      },
      {
        "key": Strings.type.tr,
        "value": ragData?.type.capitalize ?? "",
      },
      {
        "key": "Data",
        "value": ragData?.data ?? "",
      },
      {
        "key": Strings.pageNumber.tr,
        "value": ragData?.pageNumber ?? "",
      },
    ];
    return noData
        ? Row(
            children: [
              Icon(
                Symbols.info,
                size: isTablet ? 26 : 24,
                color: MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
                    .bodyMedium
                    ?.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  Strings.noKbFound.tr,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                  ),
                ),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...kbInfo.map(
                (Map<String, String> info) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${info['key']}: ",
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: info['value'] ?? "",
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}
