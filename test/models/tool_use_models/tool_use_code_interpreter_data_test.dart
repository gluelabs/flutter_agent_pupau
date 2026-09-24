import 'package:flutter_agent_pupau/models/tool_use_models/tool_use_code_interpreter_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ToolUseCodeInterpreterImage.isRenderableImage', () {
    test('accepts every allow-listed image subtype', () {
      const subtypes = ['png', 'jpg', 'jpeg', 'gif', 'webp', 'svg+xml'];
      for (final subtype in subtypes) {
        final image = ToolUseCodeInterpreterImage(
          dataUri: 'data:image/$subtype;base64,AAAA',
          description: '',
          format: subtype,
        );
        expect(
          image.isRenderableImage,
          isTrue,
          reason: 'data:image/$subtype should be renderable',
        );
      }
    });

    test('is case-insensitive on the prefix', () {
      final image = ToolUseCodeInterpreterImage(
        dataUri: 'DATA:IMAGE/PNG;base64,AAAA',
        description: '',
        format: 'png',
      );
      expect(image.isRenderableImage, isTrue);
    });

    test('rejects non-image data URIs (e.g. HTML/script), never renders them', () {
      const dangerous = [
        'data:text/html,<script>alert(1)</script>',
        'javascript:alert(1)',
        'data:application/javascript,alert(1)',
        '<img src=x onerror=alert(1)>',
      ];
      for (final value in dangerous) {
        final image = ToolUseCodeInterpreterImage(
          dataUri: value,
          description: '',
          format: '',
        );
        expect(
          image.isRenderableImage,
          isFalse,
          reason: '"$value" must never be treated as renderable',
        );
      }
    });

    test('rejects an empty or bare "data:image" with no subtype', () {
      expect(
        ToolUseCodeInterpreterImage(
          dataUri: '',
          description: '',
          format: '',
        ).isRenderableImage,
        isFalse,
      );
      expect(
        ToolUseCodeInterpreterImage(
          dataUri: 'data:image',
          description: '',
          format: '',
        ).isRenderableImage,
        isFalse,
      );
    });
  });

  group('ToolUseCodeInterpreterImage.base64Payload', () {
    test('strips everything up to and including the first comma', () {
      final image = ToolUseCodeInterpreterImage(
        dataUri: 'data:image/png;base64,AAAABBBB',
        description: '',
        format: 'png',
      );
      expect(image.base64Payload, 'AAAABBBB');
    });

    test('returns the raw string unchanged when there is no comma', () {
      final image = ToolUseCodeInterpreterImage(
        dataUri: 'AAAABBBB',
        description: '',
        format: 'png',
      );
      expect(image.base64Payload, 'AAAABBBB');
    });
  });

  group('ToolUseCodeInterpreterData.fromJson', () {
    Map<String, dynamic> sseMessage(Map<String, dynamic> response) => {
      'info': [response],
      'errors': [],
    };

    test('parses images from the response envelope', () {
      final data = ToolUseCodeInterpreterData.fromJson(
        sseMessage({
          'success': true,
          'output': 'done',
          'sandboxId': 'sbx_1',
          'sandboxCreated': true,
          'resumeFailed': false,
          'executionTime': 120,
          'images': [
            {
              'dataUri': 'data:image/png;base64,AAAA',
              'description': 'a chart',
              'format': 'png',
            },
          ],
        }),
        {
          'toolArgs': {'language': 'python', 'code': 'print(1)'},
        },
      );

      expect(data.images, hasLength(1));
      expect(data.images.single.dataUri, 'data:image/png;base64,AAAA');
      expect(data.images.single.description, 'a chart');
      expect(data.sandboxCreated, isTrue);
      expect(data.resumeFailed, isFalse);
    });

    test('defaults to an empty image list when the field is absent', () {
      final data = ToolUseCodeInterpreterData.fromJson(
        sseMessage({'success': true, 'output': 'no images here'}),
        null,
      );
      expect(data.images, isEmpty);
    });

    test('skips non-Map entries in a malformed images list instead of throwing', () {
      final data = ToolUseCodeInterpreterData.fromJson(
        sseMessage({
          'success': true,
          'output': '',
          'images': ['not-a-map', 42, null],
        }),
        null,
      );
      expect(data.images, isEmpty);
    });
  });
}
