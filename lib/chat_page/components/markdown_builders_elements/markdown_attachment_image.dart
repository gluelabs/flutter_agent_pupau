import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/attachment_image_inline.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/attachment_service.dart';
import 'package:get/get.dart';

/// `imageBuilder` for assistant markdown (`![alt](src)`).
///
/// The assistant writes a bare file name after saving a generated artifact —
/// e.g. `![grafico](grafico.png)` right after `attach_artifact` stored
/// `grafico.png`. That name is matched against the conversation's image
/// attachments and rendered inline via [AttachmentImageInline]. Remote
/// `http(s)`/`data` sources render as a plain network image; anything
/// unresolved degrades to its alt text so the message still reads.
///
/// The match is wrapped in [Obx] so a picture that is referenced before its
/// attachment finishes loading appears as soon as the attachments list lands.
///
/// Normalises a markdown image `src` to the bare, lower-cased file name used to
/// match it against an attachment — strips any directory / sandbox prefix
/// (`/mnt/data/grafico.png`, `sandbox:/…`) and percent-decoding. Returns an
/// empty string when there is nothing to match on.
String normalizeMarkdownImageSrc(String src) {
  String target = src.trim();
  try {
    target = Uri.decodeComponent(target);
  } catch (_) {
    // Leave `target` as-is on a malformed escape sequence.
  }
  target = target.toLowerCase().trim();
  if (target.contains('/')) target = target.split('/').last;
  return target;
}

/// Whether a markdown image `src` refers to the attachment named [fileName]
/// (with [extension]). Matches `grafico.png` against `fileName` "grafico" +
/// `extension` "png", and also the degenerate cases where `fileName` already
/// carries the extension or `src` omits it.
bool markdownImageSrcMatchesAttachment(
  String src,
  String fileName,
  String extension,
) {
  final String target = normalizeMarkdownImageSrc(src);
  if (target.isEmpty) return false;
  final String targetNoExt = target.contains('.')
      ? target.substring(0, target.lastIndexOf('.'))
      : target;
  final String name = fileName.toLowerCase().trim();
  if (name.isEmpty) return false;
  final String full = extension.isEmpty
      ? name
      : '$name.${extension.toLowerCase()}';
  return full == target || name == target || name == targetNoExt;
}

class MarkdownAttachmentImage extends StatelessWidget {
  const MarkdownAttachmentImage({super.key, required this.uri, this.alt});

  final Uri uri;
  final String? alt;

  Attachment? _resolveAttachment() {
    if (!Get.isRegistered<PupauAttachmentsController>()) return null;
    final String raw = uri.hasScheme ? uri.path : uri.toString();

    // `.toList()` reads the RxList so the enclosing [Obx] re-runs when the
    // attachments list changes (e.g. the just-created artifact lands).
    final List<Attachment> attachments = Get.find<PupauAttachmentsController>()
        .attachments
        .toList();
    for (final Attachment a in attachments) {
      if (AttachmentService.getAttachmentCategory(a) !=
          AttachmentCategory.image) {
        continue;
      }
      if (markdownImageSrcMatchesAttachment(raw, a.fileName, a.extension)) {
        return a;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isRemote =
        uri.isScheme('http') || uri.isScheme('https') || uri.isScheme('data');
    if (isRemote) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: Image.network(
              uri.toString(),
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (context, error, stackTrace) =>
                  _altFallback(context),
            ),
          ),
        ),
      );
    }

    if (!Get.isRegistered<PupauAttachmentsController>()) {
      return _altFallback(context);
    }

    return Obx(() {
      final Attachment? attachment = _resolveAttachment();
      if (attachment == null) return _altFallback(context);
      return AttachmentImageInline(
        key: ValueKey<String>('md_img_${attachment.id}'),
        attachmentId: attachment.id,
        fallback: _altFallback(context),
      );
    });
  }

  Widget _altFallback(BuildContext context) {
    final String? text = alt?.trim();
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_outlined,
            size: 16,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(width: 6),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
