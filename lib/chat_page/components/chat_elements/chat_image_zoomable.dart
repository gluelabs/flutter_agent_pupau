import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/utils/constants.dart';
import 'package:photo_view/photo_view.dart';

class ChatImageZoomable extends StatelessWidget {
  const ChatImageZoomable({
    super.key,
    required this.image,
  });

  final ChatImage image;

  Future<Map<String, dynamic>> _loadImageAndSize() async {
    late final ImageProvider imageProvider;

    if (image.type == ImageType.url) {
      imageProvider = CachedNetworkImageProvider(image.value, errorListener: (error) => print);
    } else {
      Uint8List bytes = base64Decode(image.value);
      imageProvider = MemoryImage(bytes);
    }

    final completer = Completer<Map<String, dynamic>>();
    final stream = imageProvider.resolve(const ImageConfiguration());

    stream.addListener(
      ImageStreamListener(
        (ImageInfo info, bool _) {
          final size = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
          completer.complete({
            'provider': imageProvider,
            'size': size,
          });
        },
        onError: (error, stackTrace) {
          completer.completeError(error);
        },
      ),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _loadImageAndSize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox();
        }
        if (snapshot.hasError) return Image.asset(Constants.missingImage);
        final imageProvider = snapshot.data!['provider'] as ImageProvider;
        final size = snapshot.data!['size'] as Size;
        bool hasDoubleHeightDifference = size.height > size.width * 2;
        return PhotoView(
          imageProvider: imageProvider,
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.contained * 3.0,
          basePosition: hasDoubleHeightDifference
              ? Alignment.topCenter
              : Alignment.center,
          initialScale: hasDoubleHeightDifference
              ? PhotoViewComputedScale.covered
              : PhotoViewComputedScale.contained,
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          errorBuilder: (context, error, stackTrace) =>
              Image.asset(Constants.missingImage),
        );
      },
    );
  }
}
