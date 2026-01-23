class ToolUseImageGenerationData {
  List<GeneratedImageData> images;

  ToolUseImageGenerationData({required this.images});

  factory ToolUseImageGenerationData.fromJson(Map<String, dynamic> json) {
    List info = json['info'] ?? [];
    Map<String, dynamic> firstInfo = info.firstOrNull ?? {};
    List imagesJson = firstInfo["images"] ?? [];
    List<GeneratedImageData> images =
        imagesJson.map((img) => GeneratedImageData.fromJson(img)).toList();

    return ToolUseImageGenerationData(images: images);
  }
}


class GeneratedImageData {
  final String id;
  final String path;
  final String imageUrlFormat;
  final ImageGenerationOptions? generationOptions;

  GeneratedImageData({
    required this.id,
    required this.path,
    required this.imageUrlFormat,
    required this.generationOptions,
  });

  factory GeneratedImageData.fromJson(Map<String, dynamic> json) {
    return GeneratedImageData(
      id: json['id'].toString(),
      path: json['path'] ?? "",
      imageUrlFormat: json['imageUrlFormat'] ?? "",
      generationOptions: json['imageGenerationOptions'] != null
          ? ImageGenerationOptions.fromJson(json['imageGenerationOptions'])
          : null,
    );
  }
}

class ImageGenerationOptions {
  final String vendor;
  final String modelId;
  final String imageStyle;
  final String aspectRatio;
  final String width;
  final String height;

  ImageGenerationOptions(
      {required this.vendor,
      required this.modelId,
      required this.imageStyle,
      required this.aspectRatio,
      required this.width,
      required this.height});

  factory ImageGenerationOptions.fromJson(Map<String, dynamic> json) {
    return ImageGenerationOptions(
        vendor: json['vendor'] ?? "",
        modelId: json['modelId'] ?? "",
        imageStyle: json['imageStyle'] ?? "",
        aspectRatio: json['aspectRatio'] ?? "",
        width: json['imageResolution']?["width"]?.toString() ?? "",
        height: json['imageResolution']?["height"]?.toString() ?? "");
  }
}

