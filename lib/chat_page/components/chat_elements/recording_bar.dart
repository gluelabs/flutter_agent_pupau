import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class RecordingBar extends StatelessWidget {
  const RecordingBar({
    super.key,
    required this.duration,
    required this.onCancel,
    required this.onSend,
    required this.isAnonymous,
  });

  final Duration duration;
  final VoidCallback onCancel;
  final VoidCallback onSend;
  final bool isAnonymous;

  String formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    final color = isAnonymous
        ? Colors.black
        : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue;
    return Row(
      children: [
        const SizedBox(width: 2),
        IconButton(
          onPressed: onCancel,
          icon: Icon(Symbols.delete, size: 24, color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm),
          tooltip: Strings.undo.tr,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Container(
            width: DeviceService.width,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                formatDuration(duration),
                style: TextStyle(
                  fontSize: isTablet ? 17 : 15,
                  fontWeight: FontWeight.w600,
                  color: MyStyles.pupauTheme(!Get.isDarkMode).redAlarm,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onSend,
          icon: Icon(Symbols.send, size: 26, color: color),
          tooltip: Strings.sendVoiceMessage.tr,
        ),
      ],
    );
  }
}
