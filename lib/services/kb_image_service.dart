import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart'
    show ValueNotifier, visibleForTesting;
import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';

/// KB image byte fetch: `GET /rag/images/:embeddingId`, the
/// same conversation-scoped auth as attachments/grounding chunks — never a
/// bare `Image.network`/`<img src>`, which would go out unauthenticated and
/// 404 (see [ApiService.dio] usage below, mirroring
/// `AttachmentService.readAttachmentImageBytes`).
///
/// A denial degrades to `null` and the caller ([KbImageInline]) renders
/// nothing at all, never a broken-image icon — a re-trained/deleted data
/// source legitimately 404s on old messages, and an error state would make
/// historical conversations look broken.
///
/// Denials are deliberately NOT cached for the process lifetime. A fetch
/// issued while the turn is still streaming is *guaranteed* to 404: the
/// backend only persists the citation-scoped serving boundary that endpoint
/// authorizes against (`extraInfo.kbImages`, and the grounding sources) at
/// the answer sink, once the full answer exists. Caching those 404s
/// permanently left every freshly streamed image invisible until an app
/// restart cleared the map. So successes cache forever, denials expire after
/// [denialTtl], and [forgetDenials] clears them outright once the turn is
/// known to be finished. [_inFlight] is what keeps the streaming rebuild
/// storm off the endpoint's rate limiter (60/60s) now that denials lapse.
class KbImageService {
  /// Successful payloads, keyed `(embeddingId, queryId, thumb)`. The bytes
  /// behind a given citation never change, so these are kept indefinitely.
  static final Map<String, Uint8List> _bytes = {};

  /// Key → when its last fetch was denied.
  static final Map<String, DateTime> _denials = {};

  /// Queries whose turn is still streaming, and when that window opened. A
  /// denial for one of these is expected rather than final — the cited-image
  /// set does not exist server side until the answer sink — so the caller
  /// keeps its skeleton up and retries instead of concluding the image is
  /// unavailable. History-loaded turns are never marked, so a 404 there
  /// still hides on the first try (a deleted data source must not make old
  /// conversations look broken).
  ///
  /// The timestamp is a backstop: the window is normally closed by
  /// [forgetDenials], but the caller's poll loop can be abandoned (its timer
  /// is shared and gets cancelled by the next turn or a conversation reset),
  /// and a turn left marked forever would keep bypassing [denialTtl].
  static final Map<String, DateTime> _streamingTurns = {};

  /// Key → the fetch currently in flight, so concurrent rebuilds share one
  /// request instead of each issuing their own.
  static final Map<String, Future<Uint8List?>> _inFlight = {};

  /// `(sequence, queryId)` of the most recent [forgetDenials]. A retry
  /// cannot be left to depend on a widget rebuild: `MarkdownWidget` only
  /// re-parses when its source text changes, so once a turn stops streaming
  /// it hands back the very same cached child widgets, Flutter skips them by
  /// identity, and a [KbImageInline] that already hid itself is never asked
  /// again for the life of that screen. Listening to this is what lets those
  /// instances recover in place; the sequence makes two clears of the same
  /// query distinct, and the id lets unaffected images ignore it.
  static final ValueNotifier<(int, String)> denialsCleared =
      ValueNotifier<(int, String)>((0, ''));

  static int _clearSequence = 0;

  /// Upper bound on how long a turn may be treated as still streaming.
  @visibleForTesting
  static Duration streamingWindow = const Duration(minutes: 2);

  /// How long a denial suppresses re-fetching. Long enough to absorb a
  /// streaming turn's rebuilds, short enough that the image appears without
  /// an app restart if [forgetDenials] never fires.
  @visibleForTesting
  static Duration denialTtl = const Duration(seconds: 20);

  /// Test seam for the HTTP call, so the caching policy can be exercised
  /// without a live backend.
  @visibleForTesting
  static Future<Uint8List?> Function(
    String embeddingId,
    String queryId,
    bool thumb,
  )?
  debugFetcher;

  static String _keyFor(String embeddingId, String queryId, bool thumb) =>
      '$embeddingId:$queryId:${thumb ? 't' : 'f'}';

  static Future<Uint8List?> getImageBytes(
    String embeddingId, {
    required String queryId,
    bool thumb = true,
  }) {
    final String cacheKey = _keyFor(embeddingId, queryId, thumb);

    final Uint8List? hit = _bytes[cacheKey];
    if (hit != null) {
      return Future<Uint8List?>.value(hit);
    }

    // A streaming turn is paced by the caller's own backoff timer, which is
    // the single authority there — a wall-clock window here as well would
    // mean two clocks racing, and a scheduled retry silently dropped while
    // the caller still counts it as an attempt spent.
    final DateTime? deniedAt = _denials[cacheKey];
    if (deniedAt != null && !isTurnStreaming(queryId)) {
      final Duration since = DateTime.now().difference(deniedAt);
      if (since < denialTtl) {
        return Future<Uint8List?>.value();
      }
    }

    final Future<Uint8List?>? pending = _inFlight[cacheKey];
    if (pending != null) {
      return pending;
    }

    final Future<Uint8List?> request = _fetch(
      embeddingId,
      queryId,
      thumb,
      cacheKey,
    );
    _inFlight[cacheKey] = request;
    return request;
  }

  static Future<Uint8List?> _fetch(
    String embeddingId,
    String queryId,
    bool thumb,
    String cacheKey,
  ) async {
    try {
      final Uint8List? bytes = debugFetcher != null
          ? await debugFetcher!(embeddingId, queryId, thumb)
          : await _get(embeddingId, queryId, thumb);
      if (bytes != null && bytes.isNotEmpty) {
        _bytes[cacheKey] = bytes;
        _denials.remove(cacheKey);
        return bytes;
      }
      _denials[cacheKey] = DateTime.now();
      return null;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  static Future<Uint8List?> _get(
    String embeddingId,
    String queryId,
    bool thumb,
  ) async {
    final String url = ApiUrls.ragImageUrl(
      embeddingId,
      queryId: queryId,
      thumb: thumb,
    );
    try {
      final PupauChatController chatController = Get.find();
      final String conversationToken =
          chatController.conversation.value?.token ?? '';
      final dio.Response<List<int>> response = await ApiService.dio
          .get<List<int>>(
            url,
            options: dio.Options(
              headers: {'Conversation-Token': conversationToken},
              responseType: dio.ResponseType.bytes,
            ),
          );
      final List<int>? bytes = response.data;
      return bytes != null ? Uint8List.fromList(bytes) : null;
    } catch (_) {
      return null;
    }
  }

  /// Marks [queryId]'s turn as live, so a 404 for one of its images reads as
  /// "not persisted yet" rather than "gone". Paired with [forgetDenials],
  /// which ends the streaming window.
  static void markTurnStreaming(String queryId) {
    if (queryId.isEmpty) return;
    _streamingTurns.putIfAbsent(queryId, DateTime.now.call);
  }

  static bool isTurnStreaming(String queryId) {
    final DateTime? since = _streamingTurns[queryId];
    if (since == null) return false;
    if (DateTime.now().difference(since) < streamingWindow) return true;
    _streamingTurns.remove(queryId);
    return false;
  }

  /// Drops every cached denial belonging to [queryId] and closes its
  /// streaming window. Called once the turn is finished and the backend has
  /// had its chance to persist that turn's cited-image set.
  static void forgetDenials(String queryId) {
    if (queryId.isEmpty) return;
    _streamingTurns.remove(queryId);
    final int before = _denials.length;
    _denials.removeWhere((String key, _) => key.contains(':$queryId:'));
    final int cleared = before - _denials.length;
    if (cleared > 0) {
      denialsCleared.value = (++_clearSequence, queryId);
    }
  }

  /// Synchronous cache peek — lets a widget paint on first build with no
  /// loading flash when the bytes are already known.
  static Uint8List? cachedImageBytes(
    String embeddingId, {
    required String queryId,
    bool thumb = true,
  }) => _bytes[_keyFor(embeddingId, queryId, thumb)];

  @visibleForTesting
  static void debugReset() {
    _bytes.clear();
    _denials.clear();
    _streamingTurns.clear();
    _inFlight.clear();
    debugFetcher = null;
    denialTtl = const Duration(seconds: 20);
    streamingWindow = const Duration(minutes: 2);
  }
}
