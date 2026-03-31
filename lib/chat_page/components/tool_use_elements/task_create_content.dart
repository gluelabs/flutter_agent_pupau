import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/task_capability_pill.dart';
import 'package:flutter_agent_pupau/chat_page/components/tool_use_elements/task_info_chip.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_task_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';

class TaskCreateContent extends StatelessWidget {
  const TaskCreateContent({
    super.key,
    required this.data,
    required this.isAnonymous,
  });

  final ToolUseTaskData data;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    final isTablet = DeviceService.isTablet;
    final fontSize = isTablet ? 16.0 : 14.0;
    final theme = MyStyles.pupauTheme(!Get.isDarkMode);
    final bodyColor = isAnonymous
        ? Colors.white
        : MyStyles.getTextTheme(isLightTheme: !Get.isDarkMode)
            .bodyMedium
            ?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          Strings.capabilities.tr,
          style: TextStyle(fontSize: fontSize, color: bodyColor),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            TaskCapabilityPill(
              label: Strings.read.tr,
              active: data.read,
              isAnonymous: isAnonymous,
              bodyColor: bodyColor,
            ),
            TaskCapabilityPill(
              label: Strings.write.tr,
              active: data.write,
              isAnonymous: isAnonymous,
              bodyColor: bodyColor,
            ),
            TaskCapabilityPill(
              label: Strings.execute.tr,
              active: data.execute,
              isAnonymous: isAnonymous,
              bodyColor: bodyColor,
            ),
          ],
        ),
        if ((data.name != null && data.name!.trim().isNotEmpty) ||
            data.taskType != null ||
            data.target != null ||
            data.cron != null ||
            data.timezone != null) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: theme.grey.withValues(alpha: isAnonymous ? 0.35 : 0.12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: fontSize,
                        color: bodyColor,
                      ),
                      children: [
                        TextSpan(
                          text: (data.name?.trim() ?? '').isNotEmpty
                              ? data.name!.trim()
                              : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (data.cron != null) const TextSpan(text: '\n'),
                        if (data.cron != null)
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${Strings.cronExpression.tr} ',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: bodyColor,
                                ),
                              ),
                            ),
                          ),
                        if (data.cron != null)
                          TextSpan(
                            text: data.cron!,
                            style: TextStyle(
                              fontSize: fontSize,
                              color: bodyColor,
                              fontFamily: 'monospace',
                            ),
                          ),
                        if (data.timezone != null) const TextSpan(text: '\n'),
                        if (data.timezone != null)
                          TextSpan(
                            text: '${Strings.timezone.tr} ',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: bodyColor,
                            ),
                          ),
                        if (data.timezone != null)
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                data.timezone!,
                                style: TextStyle(
                                  fontSize: fontSize,
                                  color: bodyColor,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (data.taskType != null || data.target != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (data.taskType != null)
                        TaskInfoChip(
                          value: data.taskType!,
                          isAnonymous: isAnonymous,
                        ),
                      if (data.taskType != null && data.target != null)
                        const SizedBox(height: 6),
                      if (data.target != null)
                        TaskInfoChip(
                          value: data.target!,
                          isAnonymous: isAnonymous,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        if (data.message.isNotEmpty ||
            (data.errors != null && data.errors!.isNotEmpty)) ...[
          const SizedBox(height: 10),
          Text(
            data.displayMessage,
            style: TextStyle(
              fontSize: fontSize,
              color: (data.errors != null && data.errors!.isNotEmpty)
                  ? theme.redAlarm
                  : bodyColor,
            ),
          ),
        ],
      ],
    );
  }
}