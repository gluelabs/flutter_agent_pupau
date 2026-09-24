import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/image_not_available_widget.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:get/get.dart';

/// Renders a conversation image attachment inline (in a message bubble or a
/// tool card) from its bytes, capped at [maxHeight]. Tapping opens the same
/// full-screen zoom viewer used for other chat images
/// ([PupauChatController.selectImage]).
///
/// Bytes are fetched via [AttachmentService.readAttachmentImageBytes] (which
/// keeps its own app-lifetime cache); if they are already cached the image
/// paints on the first frame with no spinner.
class AttachmentImageInline extends StatefulWidget {
  const AttachmentImageInline({
    super.key,
    required this.attachmentId,
    this.maxHeight = 320,
    this.fallback,
  });

  final String attachmentId;
  final double maxHeight;

  /// Shown when the bytes cannot be loaded (missing attachment, network error).
  /// Defaults to [ImageNotAvailableWidget].
  final Widget? fallback;

  @override
  State<AttachmentImageInline> createState() => _AttachmentImageInlineState();
}

class _AttachmentImageInlineState extends State<AttachmentImageInline> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final Uint8List? cached = AttachmentService.cachedAttachmentImageBytes(
      widget.attachmentId,
    );
    if (cached != null) {
      _bytes = cached;
      _loading = false;
    } else {
      _load();
    }
  }

  @override
  void didUpdateWidget(AttachmentImageInline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.attachmentId != widget.attachmentId) {
      _bytes = AttachmentService.cachedAttachmentImageBytes(widget.attachmentId);
      _loading = _bytes == null;
      if (_loading) _load();
    }
  }

  Future<void> _load() async {
    final Uint8List? bytes = await AttachmentService.readAttachmentImageBytes(
      widget.attachmentId,
    );
    if (!mounted) return;
    setState(() {
      _bytes = bytes;
      _loading = false;
    });
  }

  void _openFull() {
    final Uint8List? bytes = _bytes;
    if (bytes == null || !Get.isRegistered<PupauChatController>()) return;
    Get.find<PupauChatController>().selectImage(
      base64Encode(bytes),
      ImageType.base64,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: widget.maxHeight * 0.4,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final Uint8List? bytes = _bytes;
    if (bytes == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: widget.maxHeight * 0.4,
          child: widget.fallback ?? const ImageNotAvailableWidget(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: _openFull,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            child: Image.memory(
              bytes,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  widget.fallback ?? const ImageNotAvailableWidget(),
            ),
          ),
        ),
      ),
    );
  }
}
