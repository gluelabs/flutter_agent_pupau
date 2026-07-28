import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:flutter_agent_pupau/chat_page/components/shared/code_block.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({super.key, required this.element});

  final md.Element element;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: CodeBlock(
        text: element.textContent,
        language: element.attributes['language'] ?? 'dart',
      ),
    );
  }
}
