import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/components/chat_elements/chat_image_zoomable.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/basic_app_bar.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/chat_image_model.dart';
import 'package:flutter_agent_pupau/services/file_service.dart';
import 'package:get/get.dart';
import 'package:material_symbols_icons/symbols.dart';

class ChatImageFull extends GetView<ChatController> {
  const ChatImageFull({super.key});

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    ChatImage? image = controller.selectedImage.value;
    return Scaffold(
      appBar: BasicAppBar(
        title: "",
        isArrowWhite: true,
        iconColor: Colors.white,
        icon: Symbols.download,
        onPressed: () => image != null
            ? image.type == ImageType.url
                ? FileService.downloadImage(image.value)
                : FileService.downloadBase64Image(image.value)
            : null,
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.4),
      body: SafeArea(
        child: Obx(() {
          ChatImage? image = controller.selectedImage.value;
          return image != null
              ? ChatImageZoomable(image: image)
              : const SizedBox.shrink();
        }),
      ),
    );
  }
}
