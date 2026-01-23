import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/services/assistant_service.dart';

class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar(
      {super.key,
      required this.assistantId,
      required this.imageUuid,
      required this.radius,
      required this.format,
      this.uploadedImage,
      this.isMarketplaceUrl = false});

  final String assistantId;
  final String imageUuid;
  final double radius;
  final ImageFormat format;
  final Uint8List? uploadedImage;
  final bool isMarketplaceUrl;

  @override
  Widget build(BuildContext context) {
    String imageUrl = imageUuid != ""
        ? AssistantService.getAssistantImageUrl(
            assistantId, imageUuid, isMarketplaceUrl, format)
        : "";
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.white,
      child: ClipOval(
        child: SizedBox(
          width: radius * 2,
          height: radius * 2,
          child: uploadedImage != null
              ? Image.memory(
                  uploadedImage!,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                )
              : imageUrl != ""
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fadeInDuration: const Duration(milliseconds: 200),
                      fadeOutDuration: const Duration(milliseconds: 200),
                      fit: BoxFit.cover,
                      width: radius * 2,
                      height: radius * 2,
                      errorWidget: (context, error, stackTrace) => Image.asset(
                          AssistantService.getAssistantFallbackImage(
                              assistantId),
                          fit: BoxFit.cover,
                          width: radius * 2,
                          height: radius * 2),
                      errorListener: (e) => print)
                  : Image.asset(
                      AssistantService.getAssistantFallbackImage(assistantId),
                      fit: BoxFit.cover,
                      width: radius * 2,
                      height: radius * 2,
                    ),
        ),
      ),
    );
  }
}
