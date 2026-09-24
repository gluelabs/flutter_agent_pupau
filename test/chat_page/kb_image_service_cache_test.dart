import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agent_pupau/services/kb_image_service.dart';

/// The reported "image shows only after a full app restart" bug. A fetch
/// issued while the turn is still streaming is guaranteed to 404: the
/// backend only persists the cited-image set that
/// `GET /rag/images/:embeddingId` authorizes against at the answer sink.
/// Caching that denial for the process lifetime meant the image stayed
/// invisible on every later render — including a fresh history load — until
/// the app restarted and cleared the in-memory map.
void main() {
  setUp(KbImageService.debugReset);
  tearDown(KbImageService.debugReset);

  final Uint8List payload = Uint8List.fromList(<int>[1, 2, 3, 4]);

  test(
    'a denial collected mid-stream does not outlive the turn: once '
    'forgetDenials runs, the next fetch retries and succeeds',
    () async {
      int calls = 0;
      bool turnPersisted = false;
      KbImageService.debugFetcher = (_, _, _) async {
        calls++;
        return turnPersisted ? payload : null;
      };

      // Mid-stream: the endpoint 404s because the turn isn't persisted yet.
      expect(
        await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
        isNull,
      );
      expect(calls, 1);

      // Rebuild storm while still streaming — suppressed by the denial TTL,
      // so the endpoint's rate limiter never sees the churn.
      for (int i = 0; i < 25; i++) {
        expect(
          await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
          isNull,
        );
      }
      expect(calls, 1);

      // Turn completes; the grounding refetch proves it was persisted.
      turnPersisted = true;
      KbImageService.forgetDenials('ovw7b');

      expect(
        await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
        payload,
      );
      expect(calls, 2);
    },
  );

  test('a denial lapses on its own once the TTL passes, with no forgetDenials '
      'call at all (the safety net for turns that never refetch)', () async {
    int calls = 0;
    bool turnPersisted = false;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return turnPersisted ? payload : null;
    };
    KbImageService.denialTtl = Duration.zero;

    expect(
      await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      isNull,
    );
    expect(calls, 1);

    turnPersisted = true;
    expect(
      await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      payload,
    );
    expect(calls, 2);
  });

  test('a success is cached indefinitely and never re-fetched', () async {
    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return payload;
    };

    expect(
      await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      payload,
    );
    for (int i = 0; i < 10; i++) {
      expect(
        await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
        payload,
      );
    }
    expect(calls, 1);
    expect(
      KbImageService.cachedImageBytes('EenWg', queryId: 'ovw7b'),
      payload,
    );
  });

  test('concurrent fetches for the same image collapse into one request', () async {
    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return payload;
    };

    final List<Uint8List?> results = await Future.wait(<Future<Uint8List?>>[
      KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
    ]);

    expect(results, everyElement(payload));
    expect(calls, 1);
  });

  test('the streaming window expires on its own, so a turn whose poll loop '
      'was abandoned stops bypassing the denial TTL forever', () async {
    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return null;
    };
    KbImageService.streamingWindow = Duration.zero;
    KbImageService.markTurnStreaming('ovw7b');

    expect(KbImageService.isTurnStreaming('ovw7b'), isFalse);

    // With the window closed, the denial TTL applies again and repeated
    // asks cost nothing.
    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    for (int i = 0; i < 10; i++) {
      await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    }
    expect(calls, 1);
  });

  test('while the streaming window is open the denial TTL is bypassed, so '
      'the caller can pace its own retries', () async {
    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return null;
    };
    KbImageService.markTurnStreaming('ovw7b');

    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    expect(calls, 3);
  });

  test('forgetDenials reports which queryId it cleared, so unaffected images '
      'can ignore the notification', () async {
    KbImageService.debugFetcher = (_, _, _) async => null;
    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');

    final (int, String) before = KbImageService.denialsCleared.value;
    KbImageService.forgetDenials('ovw7b');
    final (int, String) after = KbImageService.denialsCleared.value;

    expect(after.$2, 'ovw7b');
    expect(after.$1, greaterThan(before.$1));
  });

  test('forgetDenials only clears the queryId it was given', () async {
    KbImageService.debugFetcher = (_, _, _) async => null;

    await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b');
    await KbImageService.getImageBytes('EenWg', queryId: 'other');

    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return payload;
    };

    KbImageService.forgetDenials('ovw7b');

    expect(
      await KbImageService.getImageBytes('EenWg', queryId: 'ovw7b'),
      payload,
    );
    expect(calls, 1);
    // The untouched query is still suppressed by its own denial.
    expect(
      await KbImageService.getImageBytes('EenWg', queryId: 'other'),
      isNull,
    );
    expect(calls, 1);
  });
}
