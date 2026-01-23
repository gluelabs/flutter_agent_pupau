import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:downloadsfolder/downloadsfolder.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_agent_pupau/chat_page/utils/modal_utils.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/main_editor/main_editor.dart';
import 'package:flutter_agent_pupau/services/api_service.dart';
import 'package:flutter_agent_pupau/services/device_service.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:flutter_agent_pupau/utils/translations/strings_enum.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/error_snackbar.dart';
import 'package:flutter_agent_pupau/chat_page/components/shared/feedback_snackbar.dart';
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


class FileService {
  static final safStream = SafStream();
  static final SafUtil safUtil = SafUtil();
  static final DateFormat fileFormat = DateFormat("dd-MM-yyyy-HH-mm-ss");


  //IMAGES
  static Future<Uint8List?> getImageFromUrl(String imageUrl) async {
    final http.Response responseData = await http.get(Uri.parse(imageUrl));
    Uint8List imageFromUrl = responseData.bodyBytes;
    ByteBuffer buffer = imageFromUrl.buffer;
    ByteData byteData = ByteData.view(buffer);
    Directory tempDir = await getTemporaryDirectory();
    File imageFile = await File('${tempDir.path}/${generateImageName()}')
        .writeAsBytes(
            buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return await editImage(imageFile);
  }

  static Future<List<Uint8ListWithName>> getImageFromGallery(
      {bool allowMultiple = false}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media, allowMultiple: allowMultiple, withData: true);
    if (result == null) return [];
    if (result.files.length == 1) {
      File imageFile = File(result.files.single.path!);
      Uint8List? image = await editImage(imageFile);
      return image != null
          ? [Uint8ListWithName(image: image, name: result.files.single.name)]
          : [];
    }
    return Future.wait(result.files.where((file) => file.path != null).map(
        (file) async => Uint8ListWithName(
            image: await File(file.path!).readAsBytes(), name: file.name)));
  }

  static Future<Uint8ListWithName?> getImageFromCamera() async {
    if (await Permission.camera.status == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    } else {
      try {
        XFile? result =
            await ImagePicker().pickImage(source: ImageSource.camera);
        if (result != null) {
          File imageFile = File(result.path);
          Uint8List? image = await editImage(imageFile);
          return image != null
              ? Uint8ListWithName(image: image, name: result.name)
              : null;
        }
      } catch (e) {
        DeviceService.isCameraDeniedError(e);
        return null;
      }
    }
    return null;
  }

  static Future<Uint8List?> editImage(File file) async {
    Uint8List? imageBytes;
    BuildContext? safeContext = getSafeModalContext();
    if (safeContext == null) return null;
    await Navigator.push(
        safeContext,
        MaterialPageRoute(
          builder: (context) => ProImageEditor.file(
            file,
            configs: ProImageEditorConfigs(
              cropRotateEditor: CropRotateEditorConfigs(
                  style: CropRotateEditorStyle(cropCornerColor: Colors.white)),
            ),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                imageBytes = bytes;
                Navigator.pop(context);
              },
            ),
          ),
        ));
    return imageBytes;
  }

  static Future<void> downloadImage(String imageUrl) async {
    try {
      var response = await Dio()
          .get(imageUrl, options: Options(responseType: ResponseType.bytes));

      await SaverGallery.saveImage(Uint8List.fromList(response.data),
          fileName: generateImageName(), skipIfExists: false);
      showFeedbackSnackbar(Strings.imageDownloadSuccess.tr, Symbols.photo);
    } catch (e) {
      showErrorSnackbar(Strings.imageDownloadFail.tr);
    }
  }

  static Future<void> downloadBase64Image(String imageUrl) async {
    try {
      Uint8List imageBytes = base64Decode(imageUrl);
      await SaverGallery.saveImage(imageBytes,
          fileName: generateImageName(), skipIfExists: false);
      showFeedbackSnackbar(Strings.imageDownloadSuccess.tr, Symbols.photo);
    } catch (e) {
      showErrorSnackbar(Strings.imageDownloadFail.tr);
    }
  }

  static Future<void> shareImage(String imageUrl) async {
    try {
      final url = Uri.parse(imageUrl);
      final response = await http.get(url);
      final contentType = response.headers['content-type'];
      final image = XFile.fromData(
        response.bodyBytes,
        mimeType: contentType,
      );
      await SharePlus.instance.share(ShareParams(files: [image]));
    } catch (e) {
      showErrorSnackbar(Strings.apiErrorGeneric.tr);
    }
  }

  static String generateImageName() =>
      "PupauAiImage-${fileFormat.format(DateTime.now())}";

  //FILES
  static Future<void> downloadKbFile(String fileId, String fileName,
      String assistandId, String conversationId, bool isMarketplace) async {
    String url = ApiUrls.fileDownloadUrl(assistandId, conversationId, fileId, isMarketplace: isMarketplace);
    await ApiService.call(url, RequestType.get,
        onSuccess: (response) async {
      String downloadUrl = response.data["signedUrl"];
      Directory downloadDirectory = await getDownloadDirectory();
      String fullPath = "${downloadDirectory.path}/$fileName";
      await ApiService.download(
        url: downloadUrl,
        savePath: fullPath,
        onSuccess: () => showFeedbackSnackbar(
            Strings.fileDownloadSuccess.tr, Symbols.download),
        onError: (e) => showErrorSnackbar(Strings.fileDownloadFail.tr),
      );
    });
  }

  static Future<List<File>> getFileFromDevice(
      {bool allowMultiple = false}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          withData: true,
          allowMultiple: allowMultiple,
          allowedExtensions: [
            "png",
            "jpg",
            "jpeg",
            "pdf",
            "txt",
            "csv",
            "xlsx"
          ]);
      return (result?.files ?? [])
          .map((PlatformFile file) => File(file.path.toString()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static IconData getFileIcon(String fileExtension) {
    switch (fileExtension.toLowerCase()) {
      case '.pdf':
        return Symbols.picture_as_pdf;
      case '.txt':
        return Symbols.description;
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
      case '.gif':
      case '.dng':
        return Symbols.image;
      case '.csv':
      case '.xlsx':
        return Symbols.table_chart;
      default:
        return Symbols.insert_drive_file;
    }
  }

  static String getFileType(String filePath) {
    String fileExtension = extension(filePath);
    switch (fileExtension.toLowerCase()) {
      case '.png':
      case '.jpg':
      case '.jpeg':
      case '.webp':
      case '.gif':
      case '.dng':
        return "IMAGE";
      case '.csv':
      case '.xlsx':
        return "CSV";
      default:
        return "TEXT";
    }
  }

  static Future<File?> createMdFile(String title, String content) async {
    try {
      String fileName = "$title.md";
      Directory tempDir = await getTemporaryDirectory();
      String filePath = '${tempDir.path}/$fileName';
      File file = File(filePath);
      file = await file.writeAsString(content);
      return file;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> saveToDownloads(
    String content,
    String fileName,
    String extension, // e.g., 'md', 'pdf', 'docx'
  ) async {
    try {
      Platform.isAndroid
          ? await saveToDownloadsAndroid(content, fileName, extension)
          : await saveToDownloadsIos(content, fileName, extension);
      showFeedbackSnackbar(Strings.fileDownloadSuccess.tr, Symbols.download);
      return true;
    } catch (e) {
      showErrorSnackbar(Strings.fileDownloadFail.tr);
      return false;
    }
  }

  static Future<bool> saveToDownloadsAndroid(
      String content, String fileName, String extension) async {
    try {
      // 1. Ask user for a directory (if you don’t already have one)
      //    Use SAF to open a directory picker (with write permission)
      SafDocumentFile? treeUri =
          await safUtil.pickDirectory(writePermission: true);
      if (treeUri == null) return false;

      // 2. Prepare file name and MIME type
      // e.g. fileName = “MyFile”, extension = “md” → fullName = “MyFile.md”
      String fullName = "$fileName.$extension";
      String mimeType = getMimeType(extension);

      // Convert content to bytes
      Uint8List data = Uint8List.fromList(utf8.encode(content));

      // You can either write via `writeFileBytes` for small files, or via streaming
      // For simplicity, use `writeFileBytes` here:
      await safStream.writeFileBytes(
        treeUri.uri,
        fullName,
        mimeType,
        data,
        overwrite: true,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> saveToDownloadsIos(
      String content, String fileName, String extension) async {
    try {
      Directory downloadDirectory = await getDownloadDirectory();
      final filePath = '${downloadDirectory.path}/$fileName.$extension';
      final file = File(filePath);
      await file.writeAsString(content);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Guess a MIME type from extension (very simple)
  static String getMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'txt':
        return 'text/plain';
      case 'md':
        return 'text/markdown';
      case 'json':
        return 'application/json';
      case 'pdf':
        return 'application/pdf';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'csv':
        return 'text/csv';
      default:
        return 'application/octet-stream';
    }
  }
}

class Uint8ListWithName {
  Uint8List image;
  String name;

  Uint8ListWithName({required this.image, required this.name});
}
