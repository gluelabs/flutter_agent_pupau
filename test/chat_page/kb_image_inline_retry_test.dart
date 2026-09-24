import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/kb_image_inline.dart';
import 'package:flutter_agent_pupau/services/kb_image_service.dart';

/// The widget half of the "visible only after a full app restart" bug. Even
/// with the denial cleared, element reconciliation keeps this State alive
/// across the parent's rebuilds — so an instance that already hid itself has
/// to re-ask, or the image never comes back within the same app session.
void main() {
  setUp(KbImageService.debugReset);
  tearDown(KbImageService.debugReset);

  final Uint8List onePixelPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
    'DwAChwGA60e6kgAAAABJRU5ErkJggg==',
  );

  testWidgets(
    'an instance hidden by a mid-stream denial recovers on a later rebuild '
    'once the turn is persisted',
    (tester) async {
      bool turnPersisted = false;
      KbImageService.debugFetcher = (_, _, _) async =>
          turnPersisted ? onePixelPng : null;

      late StateSetter rebuildParent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuildParent = setState;
                // Deliberately not const: a const instance is identical
                // across rebuilds, so Flutter skips the update and
                // didUpdateWidget never fires. MarkdownBody builds a fresh
                // instance on every re-parse, which is what this mirrors.
                // ignore: prefer_const_constructors
                return KbImageInline(
                  embeddingId: 'EenWg',
                  queryId: 'ovw7b',
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Denied mid-stream: nothing rendered, no broken-image icon.
      expect(find.byType(Image), findsNothing);

      // Turn completes and the refetch clears the stale denial.
      turnPersisted = true;
      KbImageService.forgetDenials('ovw7b');

      rebuildParent(() {});
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgets(
    'recovers with NO rebuild at all once denials are cleared — the live SSE '
    'case, where MarkdownWidget stops re-parsing as soon as the answer text '
    'stops changing and therefore hands back the same cached child widgets',
    (tester) async {
      bool turnPersisted = false;
      KbImageService.debugFetcher = (_, _, _) async =>
          turnPersisted ? onePixelPng : null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const KbImageInline(
              embeddingId: 'EenWg',
              queryId: 'i7u1A',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsNothing);

      // The turn completes. Nothing rebuilds this widget — a const instance
      // in a subtree nobody touches, exactly like MarkdownWidget's cached
      // children after streaming ends.
      turnPersisted = true;
      KbImageService.forgetDenials('i7u1A');
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    },
  );

  testWidgets(
    'while the turn streams, a 404 keeps the skeleton up and retries until '
    'the image is served — it must not appear only once the turn is over',
    (tester) async {
      bool turnPersisted = false;
      int calls = 0;
      KbImageService.debugFetcher = (_, _, _) async {
        calls++;
        return turnPersisted ? onePixelPng : null;
      };
      KbImageService.markTurnStreaming('i7u1A');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const KbImageInline(
              embeddingId: 'EenWg',
              queryId: 'i7u1A',
            ),
          ),
        ),
      );
      await tester.pump();

      // Denied, but the turn is live: the skeleton stays, nothing collapses.
      expect(find.byType(Image), findsNothing);
      expect(find.byType(AspectRatio), findsOneWidget);

      // The answer sink runs mid-stream; the next retry picks the image up
      // without waiting for the turn to finish.
      turnPersisted = true;
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
      expect(calls, greaterThan(1));
    },
  );

  testWidgets(
    'a history-loaded image that genuinely 404s hides immediately rather '
    'than sitting on a skeleton — no streaming turn was ever marked',
    (tester) async {
      KbImageService.debugFetcher = (_, _, _) async => null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const KbImageInline(
              embeddingId: 'EenWg',
              queryId: 'oldQuery',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsNothing);
      expect(find.byType(AspectRatio), findsNothing);
    },
  );

  testWidgets(
    'once the streaming retries are spent, rebuilds stop re-fetching — while '
    'the turn streams the denial TTL is bypassed, so an unguarded rebuild '
    'storm would become a request storm',
    (tester) async {
      int calls = 0;
      KbImageService.debugFetcher = (_, _, _) async {
        calls++;
        return null;
      };
      KbImageService.markTurnStreaming('i7u1A');

      late StateSetter rebuildParent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                rebuildParent = setState;
                // ignore: prefer_const_constructors
                return KbImageInline(
                  embeddingId: 'EenWg',
                  queryId: 'i7u1A',
                );
              },
            ),
          ),
        ),
      );
      // Burn through every scheduled streaming retry (the backoff series
      // runs to ~38s of fake time before the widget gives up).
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 5));
      }
      final int afterRetries = calls;
      expect(afterRetries, greaterThan(1));
      expect(
        find.byType(AspectRatio),
        findsNothing,
        reason: 'retries spent, so the skeleton collapses',
      );

      for (int i = 0; i < 20; i++) {
        rebuildParent(() {});
        await tester.pump();
      }

      expect(calls, afterRetries);
    },
  );

  testWidgets('a still-denied instance stays hidden and does not hammer the '
      'endpoint across a rebuild storm', (tester) async {
    int calls = 0;
    KbImageService.debugFetcher = (_, _, _) async {
      calls++;
      return null;
    };

    late StateSetter rebuildParent;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              rebuildParent = setState;
              // ignore: prefer_const_constructors
              return KbImageInline(
                embeddingId: 'EenWg',
                queryId: 'ovw7b',
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (int i = 0; i < 20; i++) {
      rebuildParent(() {});
      await tester.pump();
    }

    expect(find.byType(Image), findsNothing);
    expect(calls, 1);
  });
}
