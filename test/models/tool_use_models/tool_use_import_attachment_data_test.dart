import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_import_attachment_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> sseMessage(Map<String, dynamic> response) => {
    'info': [response],
    'errors': [],
  };

  group('ToolUseImportAttachmentData.fromJson', () {
    test('parses error from the response envelope on failure', () {
      final data = ToolUseImportAttachmentData.fromJson(
        sseMessage({'success': false, 'error': 'Attachment not found'}),
        {
          'toolArgs': {'attachment_id': 'att_1', 'path': '/workspace/in.csv'},
        },
      );

      expect(data.success, isFalse);
      expect(data.error, 'Attachment not found');
    });

    test('error defaults to empty string when the field is absent', () {
      final data = ToolUseImportAttachmentData.fromJson(
        sseMessage({'success': true, 'fileName': 'in.csv', 'path': '/ws/in.csv'}),
        null,
      );
      expect(data.error, isEmpty);
    });
  });
}
