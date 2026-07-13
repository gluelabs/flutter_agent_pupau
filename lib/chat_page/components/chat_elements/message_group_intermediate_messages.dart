import 'package:flutter/material.dart';

/// Animated container for the intermediate messages of a grouped row.
class MessageGroupIntermediateMessages extends StatelessWidget {
  const MessageGroupIntermediateMessages({
    super.key,
    required this.groupId,
    required this.isExpanded,
    required this.hasIntermediates,
    required this.child,
  });

  final String groupId;
  final bool isExpanded;
  final bool hasIntermediates;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      key: ValueKey<String>('group_intermediate_$groupId'),
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
      curve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
      clipBehavior: Clip.hardEdge,
      child: (isExpanded && hasIntermediates)
          ? child
          : const SizedBox(width: double.infinity),
    );
  }
}

