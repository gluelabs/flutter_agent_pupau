import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_to_do_list_data.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ToDoItem extends StatelessWidget {
  const ToDoItem({
    super.key,
    required this.task,
    this.isAnonymous = false,
  });

  final ToDoTask task;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    bool isDone = task.isDone;
    String? itemId = task.itemId;
    String text = itemId != null ? "#$itemId ${task.task}" : task.task;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(children: [
        Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                  color: isAnonymous
                      ? AnonymousThemeColors.userBubble
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue),
              borderRadius: BorderRadius.circular(6),
              color: isDone
                  ? isAnonymous
                      ? AnonymousThemeColors.userBubble
                      : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue
                  : isAnonymous
                      ? Colors.transparent
                      : MyStyles.pupauTheme(!Get.isDarkMode).white,
            ),
            child: isDone
                ? Icon(Symbols.check,
                    size: 18,
                    color: isAnonymous
                        ? Colors.black
                        : MyStyles.pupauTheme(!Get.isDarkMode).white)
                : null),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: isAnonymous ? Colors.white : null,
                  decoration: isDone ? TextDecoration.lineThrough : null),
              maxLines: 3),
        )
      ]),
    );
  }
}
