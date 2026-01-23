class PromptReflection {
  final String messageId;
  final String text;
  final String evaluation;

  PromptReflection({
    required this.messageId,
    required this.text,
    required this.evaluation,
  });

  bool get isPositive => evaluation.toUpperCase() == 'POSITIVE';
}
