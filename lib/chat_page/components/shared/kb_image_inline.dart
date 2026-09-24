import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/services/kb_image_service.dart';
import 'package:get/get.dart';

/// Renders one allowlisted `<kb-image>` inline. Fetches the
/// thumbnail via [KbImageService] (never a bare `Image.network`/`<img src>`
/// — the endpoint is conversation-authenticated) and shows nothing at all —
/// no icon, no placeholder, no toast — on a denied/404 fetch (§6.2): a
/// re-trained or deleted data source legitimately 404s on old messages, and
/// an error state would make historical conversations look broken.
class KbImageInline extends StatefulWidget {
  const KbImageInline({
    super.key,
    required this.embeddingId,
    required this.queryId,
    this.name,
    this.pageNumber,
    this.aspectRatio,
  });

  final String embeddingId;
  final String queryId;
  final String? name;
  final int? pageNumber;

  /// Live-frame size hint (width/height), when known — reserves layout space
  /// for the skeleton before the thumbnail loads (§5.2). Null on history
  /// reload, where the ref doesn't carry it.
  final double? aspectRatio;

  @override
  State<KbImageInline> createState() => _KbImageInlineState();
}

class _KbImageInlineState extends State<KbImageInline> {
  static const double _maxHeight = 320;
  static const double _fallbackAspectRatio = 16 / 9;

  /// Enough attempts to cover a long turn, but finite so a stream that dies
  /// mid-flight collapses the skeleton instead of spinning forever.
  static const int _maxStreamingAttempts = 12;

  bool _loading = true;
  bool _hidden = false;
  Uint8List? _thumbBytes;
  Timer? _retryTimer;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    final Uint8List? cached = KbImageService.cachedImageBytes(
      widget.embeddingId,
      queryId: widget.queryId,
    );
    if (cached != null) {
      _thumbBytes = cached;
      _loading = false;
    } else {
      _load();
    }
    KbImageService.denialsCleared.addListener(_onDenialsCleared);
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    KbImageService.denialsCleared.removeListener(_onDenialsCleared);
    super.dispose();
  }

  /// The turn finished and its stale 404s were dropped. Waiting for a rebuild
  /// is not an option here: `MarkdownWidget` re-parses only when its source
  /// text changes, so after streaming stops it reuses the same cached child
  /// widgets and this State is never handed a new one.
  void _onDenialsCleared() {
    if (_thumbBytes != null) return;
    if (KbImageService.denialsCleared.value.$2 != widget.queryId) return;
    _attempts = 0;
    _retryTimer?.cancel();
    _load();
  }

  @override
  void didUpdateWidget(KbImageInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.embeddingId != widget.embeddingId ||
        oldWidget.queryId != widget.queryId) {
      _thumbBytes = KbImageService.cachedImageBytes(
        widget.embeddingId,
        queryId: widget.queryId,
      );
      _hidden = false;
      _loading = _thumbBytes == null;
      if (_loading) _load();
      return;
    }
    // Same ids, but this instance is sitting on a failed fetch. Element
    // reconciliation keeps this State alive across the parent's rebuilds, so
    // without re-asking here the widget would stay hidden for good — which is
    // exactly what made a streamed image invisible until an app restart. The
    // denial TTL and in-flight dedup make asking cheap, except while the turn
    // streams (where the TTL is deliberately bypassed), so once this
    // instance has spent its retries it must stop asking or a rebuild storm
    // becomes a request storm.
    if (_hidden && _attempts < _maxStreamingAttempts) _load();
  }

  Future<void> _load() async {
    final Uint8List? bytes = await KbImageService.getImageBytes(
      widget.embeddingId,
      queryId: widget.queryId,
    );
    if (!mounted) return;

    if (bytes != null) {
      _retryTimer?.cancel();
      setState(() {
        _thumbBytes = bytes;
        _loading = false;
        _hidden = false;
      });
      return;
    }

    // The turn that cited this image is still streaming, so the endpoint
    // cannot serve it yet — that is not the same as unavailable. Hold the
    // skeleton and keep asking, so the image appears the moment the answer
    // sink persists it rather than waiting for the whole turn to wrap up.
    final bool stillStreaming = KbImageService.isTurnStreaming(widget.queryId);
    if (stillStreaming && _attempts < _maxStreamingAttempts) {
      _attempts++;
      if (_hidden || !_loading) {
        setState(() {
          _loading = true;
          _hidden = false;
        });
      }
      _scheduleRetry();
      return;
    }

    if (_hidden && !_loading) return;
    setState(() {
      _thumbBytes = null;
      _loading = false;
      _hidden = true;
    });
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final int delayMs = (400 * (1 << (_attempts - 1).clamp(0, 4))).clamp(
      400,
      4000,
    );
    _retryTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted) _load();
    });
  }

  void _openViewer() {
    final Uint8List? thumb = _thumbBytes;
    if (_hidden || thumb == null) return;
    final PupauChatController controller = Get.find<PupauChatController>();
    final String thumbBase64 = base64Encode(thumb);
    controller.selectImage(thumbBase64, ImageType.base64);
    _swapInFullSize(controller, thumbBase64);
  }

  /// The viewer opens on the thumb already in memory, then upgrades to the
  /// full-size image when it lands — [ChatImageFull] renders
  /// [PupauChatController.selectedImage] inside an `Obx`, so replacing the
  /// value swaps the image in place. A denied full-size fetch simply leaves
  /// the thumb up: never an error, never a closed viewer.
  Future<void> _swapInFullSize(
    PupauChatController controller,
    String thumbBase64,
  ) async {
    final Uint8List? full = await KbImageService.getImageBytes(
      widget.embeddingId,
      queryId: widget.queryId,
      thumb: false,
    );
    if (full == null) return;
    // Only upgrade while the viewer is still on our thumb — by now the user
    // may have closed it or opened a different image.
    if (controller.selectedImage.value?.value != thumbBase64) return;
    controller.selectedImage.value = ChatImage(
      value: base64Encode(full),
      type: ImageType.base64,
    );
  }

  @override
  Widget build(BuildContext context) {
    // §6.2: a denied image disappears in silence — no icon, no toast, the
    // surrounding text stays intact.
    if (_hidden) return const SizedBox.shrink();

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio ?? _fallbackAspectRatio,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }

    final Uint8List bytes = _thumbBytes!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _openViewer,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: _maxHeight),
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              gaplessPlayback: true,
              // A corrupt/truncated payload degrades the same as a 404 would
              // — nothing visible, never a broken-image icon.
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}
