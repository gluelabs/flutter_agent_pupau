import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/conversation_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';

class WebSearchTypeIndicator extends StatelessWidget {
  const WebSearchTypeIndicator({super.key, required this.webSearchType});

  final WebSearchType webSearchType;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Icon(ConversationService.getWebSearchTypeIcon(webSearchType),
          size: isTablet ? 28 : 24),
    );
  }
}
