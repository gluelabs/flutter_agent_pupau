import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:get/get.dart';

/// Expand/collapse toggle for a grouped message row.
///
/// Rules (kept identical):
/// - When collapsed: show **Expand** only under the user message.
/// - When expanded: show **Collapse** under the user message AND above last assistant.
class MessageGroupToggleButton extends StatelessWidget {
  const MessageGroupToggleButton({
    super.key,
    required this.groupId,
    required this.isExpanded,
    required this.isUnderUserMessage,
    required this.onPressed,
    this.collapsedCount = 0,
  });

  final String groupId;
  final bool isExpanded;
  final bool isUnderUserMessage;
  final VoidCallback onPressed;
  final int collapsedCount;

  @override
  Widget build(BuildContext context) {
    final bool shouldShow = isExpanded ? true : isUnderUserMessage;

    final bool isTablet = DeviceService.isTablet;
    final ThemeData theme = Theme.of(context);
    final Color subtleLabelColor = theme.colorScheme.onSurfaceVariant;
    final String label = isExpanded
        ? Strings.collapse.tr
        : (collapsedCount > 0
            ? '${Strings.expand.tr} ($collapsedCount)'
            : Strings.expand.tr);

    final Widget button = SizedBox(
      key: ValueKey<String>('group_toggle_${groupId}_${isUnderUserMessage}_$label'),
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(right: 20),
        child: Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: subtleLabelColor,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                color: subtleLabelColor,
              ),
            ),
          ),
        ),
      ),
    );

    return AnimatedSize(
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        reverseDuration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: shouldShow
            ? button
            : const SizedBox(
                key: ValueKey<String>('group_toggle_hidden'),
                width: double.infinity,
              ),
      ),
    );
  }
}

