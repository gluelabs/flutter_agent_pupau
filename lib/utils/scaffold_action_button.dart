import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';

/// Helper widget that wraps IconButton and provides Scaffold context
/// Use this in AppBarConfig.actions to safely open drawers
class ScaffoldActionButton extends StatelessWidget {
  final IconData icon;
  final String? tooltip;
  final VoidCallback? onPressed;
  final double? iconSize;
  final Color? color;
  final bool isTablet;

  const ScaffoldActionButton({
    super.key,
    required this.icon,
    this.tooltip,
    this.onPressed,
    this.iconSize,
    this.color,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (builderContext) {
        return IconButton(
          icon: Icon(icon),
          iconSize: iconSize ?? (isTablet ? 26 : 24),
          color: color,
          tooltip: tooltip,
          onPressed: onPressed != null
              ? () {
                  // Use builderContext which has access to Scaffold
                  // Or use controller methods as fallback
                  try {
                    onPressed?.call();
                  } catch (e) {
                    // If Scaffold.of() fails, use controller methods
                    if (Get.isRegistered<PupauChatController>()) {
                      final controller = Get.find<PupauChatController>();
                      // Try to determine which drawer to open based on context
                      // Default to endDrawer for mobile
                      controller.openEndDrawer();
                    }
                  }
                }
              : null,
        );
      },
    );
  }
}
