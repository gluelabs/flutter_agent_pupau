import 'package:flutter_agent_pupau/services/json_parse_service.dart';

class ToolUseMailData {
  final String to;
  final String subject;
  final String body;
  final String cc;
  final String bcc;
  final bool attachConversation;
  final String statusMessage;

  const ToolUseMailData({
    required this.to,
    required this.subject,
    required this.body,
    required this.cc,
    required this.bcc,
    required this.attachConversation,
    required this.statusMessage,
  });

  factory ToolUseMailData.fromToolUseMessage({
    required Map<String, dynamic> message,
    required Map<String, dynamic>? typeDetails,
  }) {
    final Map<String, dynamic> toolArgs =
        (typeDetails?['toolArgs'] as Map?)?.cast<String, dynamic>() ?? {};

    return ToolUseMailData(
      to: getString(toolArgs['to']),
      subject: getString(toolArgs['subject']),
      body: getString(toolArgs['body']),
      cc: getString(toolArgs['cc']),
      bcc: getString(toolArgs['bcc']),
      attachConversation: getBool(toolArgs['attachConversation']),
      statusMessage: getString(message['message']),
    );
  }

  bool get hasHtmlBody {
    final String b = body.trim().toLowerCase();
    return b.contains('<html') || b.contains('<body') || b.contains('<div');
  }

  String get bodyPlaintextPreview {
    final String b = body.trim();
    if (b.isEmpty) return '';
    final String withoutTags = b.replaceAll(RegExp(r'<[^>]+>'), ' ');
    final String collapsed = withoutTags.replaceAll(RegExp(r'\s+'), ' ').trim();
    return collapsed;
  }
}

