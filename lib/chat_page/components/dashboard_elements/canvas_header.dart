import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_dashboard_controller.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class CanvasHeader extends GetView<ChatDashboardController> {
  const CanvasHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isTablet = DeviceService.isTablet;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 4, top: 2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Symbols.close),
                onPressed: controller.clearCanvasItem,
                tooltip: Strings.back.tr,
              ),
            ],
          ),
        ),
        Opacity(opacity: 0.4, child: Divider(height: 0.25)),
        const SizedBox(height: 2),
      ],
    );
  }
}
