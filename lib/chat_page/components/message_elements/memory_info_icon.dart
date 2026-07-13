import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class MemoryInfoIcon extends GetView<PupauChatController> {
  const MemoryInfoIcon({super.key, required this.message, required this.onTap});

  final PupauMessage message;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final bool isAnonymous = controller.isAnonymous;
    final bool hasAny =
        message.alwaysMemories.isNotEmpty ||
        message.memoryReferences.isNotEmpty;
    final bool shouldShow = hasAny && message.status != MessageStatus.loading;
    return Visibility(
      visible: shouldShow,
      child: Tooltip(
        message: Strings.memoriesUsed.tr,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Icon(
              Symbols.psychology,
              size: DeviceService.isTablet ? 24 : 20,
              opticalSize: 1,
              grade: 150,
              color: isAnonymous
                  ? Colors.white
                  : MyStyles.pupauTheme(!Get.isDarkMode).primary,
            ),
          ),
        ),
      ),
    );
  }
}
