import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:get/get.dart';

class ChatAudioLabel extends StatelessWidget {
  const ChatAudioLabel({super.key, required this.isAnonymous});

  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, 8),
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Text(
          "AUDIO",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: DeviceService.isTablet ? 10 : 8,
            color: isAnonymous || Get.isDarkMode
                ? Colors.white70
                : Colors.black45,
          ),
        ),
      ),
    );
  }
}
