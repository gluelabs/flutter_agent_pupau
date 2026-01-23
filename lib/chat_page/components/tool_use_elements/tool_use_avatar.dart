import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/utils/translations/theme/my_styles.dart';

class ToolUseAvatar extends StatelessWidget {
  const ToolUseAvatar({
    super.key,
    required this.toolUseIcon,
    this.radius = 14,
    this.size,
    this.isAnonymous = false,
  });

  final IconData? toolUseIcon;
  final double radius;
  final double? size;
  final bool isAnonymous;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: Icon(
        toolUseIcon,
        color: isAnonymous
            ? Colors.white
            : MyStyles.pupauTheme(!Get.isDarkMode).darkBlue,
        size: size,
      ),
    );
  }
}
