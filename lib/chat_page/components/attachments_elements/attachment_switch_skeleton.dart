import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/custom_switch.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AttachmentCardSkeleton extends GetView<ChatController> {
  const AttachmentCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6.5),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(FileService.getFileIcon(".txt"),
                      size: isTablet ? 42 : 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Attachment.txt",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                fontWeight: FontWeight.w500)),
                        Text(
                          "10 tokens",
                          style: TextStyle(fontSize: isTablet ? 14 : 12),
                        )
                      ],
                    ),
                  ),
                  Skeletonizer(
                    enabled: true,
                    child: Transform.scale(
                        scale: 0.7,
                        child: CustomSwitch(
                            isActive: true, onChanged: (bool active) {})),
                  )
                ],
              ),
            ),
            IconButton(
                onPressed: () {},
                icon: Icon(Icons.delete,
                    size: isTablet ? 28 : 24, color: Colors.red))
          ],
        ),
      ),
    );
  }
}
