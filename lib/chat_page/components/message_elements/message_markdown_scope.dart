import 'package:flutter/material.dart';

/// Provides [messageId] for markdown subtree builders (e.g. Mermaid height cache).
class MessageMarkdownScope extends InheritedWidget {
  const MessageMarkdownScope({
    super.key,
    required this.messageId,
    required super.child,
  });

  final String messageId;

  static MessageMarkdownScope? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MessageMarkdownScope>();
  }

  @override
  bool updateShouldNotify(MessageMarkdownScope oldWidget) =>
      messageId != oldWidget.messageId;
}
