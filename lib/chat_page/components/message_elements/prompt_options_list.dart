import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/message_elements/prompt_option_button.dart';
import 'package:flutter_agent_pupau/models/prompt_option_model.dart';

class PromptOptionsList extends StatelessWidget {
  const PromptOptionsList({
    super.key,
    required this.options,
  });

  final List<PromptOption> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 4, left: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options
            .map((option) => PromptOptionButton(option: option))
            .toList(),
      ),
    );
  }
}
