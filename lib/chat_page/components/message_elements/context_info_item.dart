import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/anonymous_theme_colors.dart';

class ContextInfoItem extends StatelessWidget {
  const ContextInfoItem({
    super.key,
    required this.label,
    required this.info,
    this.isAnonymous = false,
  });

  final String label;
  final String info;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    bool isTablet = DeviceService.isTablet;
    double fontSize = isTablet ? 16 : 14;
    return Wrap(
      children: [
        Text("$label: ",
            style: TextStyle(
                fontSize: fontSize,
                color:
                    isAnonymous ? AnonymousThemeColors.assistantText : null)),
        Text(info,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color:
                    isAnonymous ? AnonymousThemeColors.assistantText : null)),
      ],
    );
  }
}
