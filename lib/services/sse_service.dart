import 'dart:async';
import 'dart:convert';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/utils/pupau_shared_preferences.dart';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_agent_pupau/utils/api_urls.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class SSEService {
  static Future<Stream<SSEModel>?> createSSEStream(
    String assistantId,
    String conversationId,
    String conversationToken,
    String message, {
    bool isWebSearch = false,
    bool isExternalSearch = false,
    ChatController? chatController,
  }) async {
    try {
      // Getting authentication credentials from the config
      final Map<String, String>? authParams =
          chatController?.pupauConfig?.authHeaders;
      if (authParams == null) return null;

      // Generating query parameters
      String queryParams = "";
      List<String> params = [];
      if (chatController?.pupauConfig?.isAnonymous ?? false) {
        params.add(
          "encryptionPass=${PupauSharedPreferences.getAnonymousConversationKey()}",
        );
      }
      if (isExternalSearch) {
        params.add("override=true");
      }
      if (isWebSearch) {
        params.add("websearch=true");
      }
      if (chatController?.pupauConfig?.customProperties != null) {
        params.add(
          "customProperties=${jsonEncode(chatController?.pupauConfig?.customProperties)}",
        );
      }
      if (params.isNotEmpty) {
        queryParams = "&${params.join('&')}";
      }

      bool isMarketplace = chatController?.pupauConfig?.isMarketplace ?? false;

      // Generating URL
      String url =
          "${ApiUrls.sendQueryUrl(assistantId, conversationId, isMarketplace: isMarketplace)}$queryParams";

      // Creating SSE stream
      Stream<SSEModel> messageSendStream = SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: url,
        header: {
          ...authParams,
          "Conversation-Token": conversationToken,
          "Content-type": "Application/json",
        },
        body: generateBody(message),
      );
      return messageSendStream;
    } catch (e) {
      return null;
    }
  }
  static Future<Stream<SSEModel>?> createSSEStreamAudio(
    String assistantId,
    String conversationId,
    String conversationToken,
    File audioFile, {
    bool isWebSearch = false,
    ChatController? chatController,
    String? language,
    }
  ) async {

         // Getting authentication credentials from the config
      final Map<String, String>? authParams =
          chatController?.pupauConfig?.authHeaders;
      if (authParams == null) return null;

    String queryParams = "";
      List<String> params = [];
      if (chatController?.pupauConfig?.isAnonymous ?? false) {
        params.add(
          "encryptionPass=${PupauSharedPreferences.getAnonymousConversationKey()}",
        );
      }
      if (isWebSearch) {
        params.add("websearch=true");
      }
      if (chatController?.pupauConfig?.customProperties != null) {
        params.add(
          "customProperties=${jsonEncode(chatController?.pupauConfig?.customProperties)}",
        );
      }
      if (params.isNotEmpty) {
        queryParams = "&${params.join('&')}";
      }

      bool isMarketplace = chatController?.pupauConfig?.isMarketplace ?? false;

       // Generating URL
      String url =
          "${ApiUrls.sendAudioQueryUrl(assistantId, conversationId, isMarketplace: isMarketplace)}$queryParams";

    final request = await buildAudioMultipartRequest(
      url: url,
      audioFile: audioFile,
      headers: {
        "Conversation-Token": conversationToken,
        ...authParams,
        "Accept": "text/event-stream",
      },
      language: language,
    );
    if (request == null) return null;

    final StreamController<SSEModel> controller = StreamController<SSEModel>();
    request.send().then((response) async {
      if (response.statusCode < 200 || response.statusCode >= 300) {
        controller.close();
        return;
      }
      final contentType =
          response.headers['content-type']?.toLowerCase() ?? '';
      if (contentType.contains('application/json')) {
        try {
          final chunks = await response.stream.toList();
          final body =
              utf8.decode(chunks.expand((x) => x).toList());
          if (body.trim().isNotEmpty) {
            controller.add(SSEModel(data: body.trim(), id: '', event: ''));
          }
        } catch (e) {
          controller.addError(e);
        }
        controller.close();
        return;
      }
      final byteStream = response.stream;
      final stringStream = utf8.decoder.bind(byteStream);
      final lineStream = const LineSplitter().bind(stringStream);
      _parseSSEStream(lineStream).listen(
        (event) => controller.add(event),
        onError: (e) {
          controller.addError(e);
          controller.close();
        },
        onDone: () => controller.close(),
        cancelOnError: false,
      );
    }).catchError((e, st) {
      controller.addError(e);
      controller.close();
    });
    return Future<Stream<SSEModel>?>.value(controller.stream);
  }

  /// Builds multipart request matching API: sse, systemLang, customProperties, audio file (Content-Type: audio/mpeg).
  static Future<http.MultipartRequest?> buildAudioMultipartRequest({
    required String url,
    required File audioFile,
    required Map<String, String> headers,
    String? language,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      // Form fields as in API example
      request.fields['sse'] = 'true';
      request.fields['systemLang'] =
          language?.replaceAll('_', '-') ??
          Get.locale?.toString().replaceAll('_', '-') ??
          'en-US';
      request.fields['customProperties'] = '{}';

        final filename = audioFile.path.split(Platform.pathSeparator).last;
      final extension = filename.toLowerCase().split('.').last;

      http.MediaType contentType;
      if (extension == 'wav') {
        contentType = http.MediaType('audio', 'wav');
      } else if (extension == 'm4a' || extension == 'aac') {
        contentType = http.MediaType('audio', 'm4a');
      } else {
        contentType = http.MediaType('audio', 'mpeg');
      }

      // Audio file with Content-Type: audio/mpeg
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: filename,
        contentType: contentType,
      ));

      final attachments = Get.find<AttachmentsController>()
          .attachments
          .where((Attachment a) => a.active)
          .toList();
      if (attachments.isNotEmpty) {
        request.fields['attachments'] = jsonEncode(
          attachments.map((a) => {"id": a.id, "mode": "STANDARD"}).toList(),
        );
      }
      return request;
    } catch (e) {
      return null;
    }
  }

  static Stream<SSEModel> _parseSSEStream(Stream<String> lines) async* {
    final List<String> dataBuffer = [];
    await for (final String line in lines) {
      if (line.startsWith("data:")) {
        dataBuffer.add(line.length > 5 ? line.substring(5) : "");
      } else if (line.trim().isEmpty) {
        if (dataBuffer.isNotEmpty) {
          final payload = dataBuffer.join("\n").trim();
          dataBuffer.clear();
          if (payload.isNotEmpty) {
            yield SSEModel(data: payload, id: '', event: '');
          }
        }
      } else {
        if (dataBuffer.isNotEmpty) {
          final payload = dataBuffer.join("\n").trim();
          dataBuffer.clear();
          if (payload.isNotEmpty) {
            yield SSEModel(data: payload, id: '', event: '');
          }
        }
        if (line.contains("\t") && line.contains("{")) {
          final start = line.indexOf("{");
          final end = line.lastIndexOf("}");
          if (start >= 0 && end > start) {
            final payload = line.substring(start, end + 1);
            if (payload.isNotEmpty) {
              yield SSEModel(data: payload, id: '', event: '');
            }
          }
        }
      }
    }
    if (dataBuffer.isNotEmpty) {
      final payload = dataBuffer.join("\n").trim();
      if (payload.isNotEmpty) {
        yield SSEModel(data: payload, id: '', event: '');
      }
    }
  }


  static Map<String, dynamic> generateBody(String message) {
    List<Attachment> attachments = Get.find<AttachmentsController>().attachments
        .where((Attachment attachment) => attachment.active)
        .toList();
    if (attachments.isEmpty) {
      return {"request": message};
    } else {
      return {
        "request": message,
        "attachments": attachments
            .map((attachment) => {"id": attachment.id, "mode": "STANDARD"})
            .toList(),
      };
    }
  }
}
