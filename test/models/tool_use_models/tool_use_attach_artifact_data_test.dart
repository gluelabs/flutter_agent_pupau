import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_attach_artifact_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<String, dynamic> sseMessage(Map<String, dynamic> response) => {
    'info': [response],
    'errors': [],
  };

  group('ToolUseAttachArtifactData.fromJson', () {
    test('parses error from the response envelope on failure', () {
      final data = ToolUseAttachArtifactData.fromJson(
        sseMessage({'success': false, 'error': 'Unsupported file format'}),
        {
          'toolArgs': {'path': '/workspace/out.bin', 'filename': 'out.bin'},
        },
      );

      expect(data.success, isFalse);
      expect(data.error, 'Unsupported file format');
    });

    test('error defaults to empty string when the field is absent', () {
      final data = ToolUseAttachArtifactData.fromJson(
        sseMessage({'success': true, 'fileName': 'chart.png'}),
        null,
      );
      expect(data.error, isEmpty);
    });
  });
}
