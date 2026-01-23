import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class ToolUseAskUserData {
  final String question;
  final AskUserChoiceType choiceType;
  final bool isMultiselect;
  final List<AskUserChoice> choices;
  final int? suggestedChoiceIndex;

  ToolUseAskUserData(
      {required this.question,
      required this.choiceType,
      required this.isMultiselect,
      required this.choices,
      required this.suggestedChoiceIndex});

  factory ToolUseAskUserData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> toolArgs = json["toolArgs"] ?? {};
    return ToolUseAskUserData(
      question: toolArgs["question"] ?? "",
      choiceType: getChoiceType(toolArgs["responseType"]),
      isMultiselect: toolArgs["multiselect"] ?? false,
      choices: toolArgs["choices"] is String
          ? (toolArgs["choices"] as String)
              .split(',')
              .map((e) => e.trim())
              .where((String e) => e.isNotEmpty)
              .toList()
              .asMap()
              .entries
              .map((entry) =>
                  AskUserChoice(choice: entry.value, index: entry.key))
              .toList()
          : (toolArgs["choices"] is List
              ? (toolArgs["choices"] as List)
                  .asMap()
                  .entries
                  .map((entry) => AskUserChoice(
                      choice: entry.value.toString(), index: entry.key))
                  .toList()
              : []),
      suggestedChoiceIndex: toolArgs["suggestedChoiceIndex"] == null
          ? null
          : getInt(toolArgs["suggestedChoiceIndex"]),
    );
  }

  static AskUserChoiceType getChoiceType(String? choiceType) {
    if (choiceType == null) return AskUserChoiceType.choice;
    switch (choiceType.toLowerCase()) {
      case "choice":
        return AskUserChoiceType.choice;
      case "text":
        return AskUserChoiceType.text;
      default:
        return AskUserChoiceType.choice;
    }
  }
}

class AskUserChoice {
  final String choice;
  final int index;

  AskUserChoice({required this.choice, required this.index});
}

enum AskUserChoiceType { choice, text }
