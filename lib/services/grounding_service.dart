import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/grounding_model.dart';
import 'package:flutter_agent_pupau/models/kb_image_model.dart';
import 'package:flutter_agent_pupau/models/pupau_message_model.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';

/// Result of [GroundingService.refetchQueryGrounding] — bundled since both
/// blocks live on the same persisted row and are fetched with one call
/// (`extraInfo.kbImages` is the post-turn allowlist for a KB-tool-only
/// turn, resolved the same way `extraInfo.grounding` is).
class GroundingRefetchResult {
  final GroundingInfo? grounding;
  final List<KbImageRef> kbImages;
  final String? kbImagesQueryId;

  const GroundingRefetchResult({
    this.grounding,
    this.kbImages = const [],
    this.kbImagesQueryId,
  });
}

class GroundingService {
  /// Click-to-reveal cache — never eager-fetched (§2.2 rate limit note).
  /// A denied chunk (404) is cached as `null` too, so re-tapping the same
  /// chip doesn't re-hit the endpoint.
  static final Map<String, GroundingChunkSnippet?> _snippetCache = {};

  static Future<GroundingChunkSnippet?> getChunkSnippet(
    String embeddingId, {
    required String queryId,
  }) async {
    if (_snippetCache.containsKey(embeddingId)) {
      return _snippetCache[embeddingId];
    }
    GroundingChunkSnippet? snippet;
    await ApiService.call(
      ApiUrls.groundingChunkUrl(embeddingId, queryId: queryId),
      RequestType.get,
      onSuccess: (response) {
        if (response.data is Map) {
          snippet = GroundingChunkSnippet.fromJson(
            Map<String, dynamic>.from(response.data as Map),
          );
        }
      },
      // 404 (or any other failure) degrades to "preview unavailable" —
      // never surfaced as an error state (§2.2).
      onError: (e) {},
    );
    _snippetCache[embeddingId] = snippet;
    return snippet;
  }

  /// Light single-query refetch after `last:true` (§1.2) — the only way to
  /// get the turn's authoritative `grounding` block on the live stream.
  ///
  /// Gotcha: on this endpoint `extraInfo` is a raw JSON string, unlike the
  /// history list endpoint where it's already parsed — decode it in place
  /// so it can be fed through the same [PupauMessage.fromLoadedChat] parser.
  static Future<GroundingRefetchResult> refetchQueryGrounding(
    String queryId,
  ) async {
    final PupauChatController chatController = Get.find();
    final String assistantId = chatController.assistantId;
    final String conversationId = chatController.conversation.value?.id ?? '';
    if (assistantId.isEmpty || conversationId.isEmpty || queryId.isEmpty) {
      return const GroundingRefetchResult();
    }
    GroundingRefetchResult result = const GroundingRefetchResult();
    await ApiService.call(
      ApiUrls.queryUrl(
        assistantId,
        conversationId,
        queryId,
        mode: chatController.agentMode,
      ),
      RequestType.get,
      onSuccess: (response) {
        if (response.data is! Map) return;
        final Map<String, dynamic> raw = Map<String, dynamic>.from(
          response.data as Map,
        );
        final dynamic extraInfo = raw['extraInfo'];
        if (extraInfo is String && extraInfo.trim().isNotEmpty) {
          try {
            raw['extraInfo'] = jsonDecode(extraInfo);
          } catch (_) {
            return;
          }
        }
        final PupauMessage refetched = PupauMessage.fromLoadedChat(raw);
        result = GroundingRefetchResult(
          grounding: refetched.grounding,
          kbImages: refetched.kbImages,
          kbImagesQueryId: refetched.kbImagesQueryId,
        );
      },
      onError: (e) {},
    );
    return result;
  }
}
