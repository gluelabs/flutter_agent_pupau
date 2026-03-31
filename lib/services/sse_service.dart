import 'dart:async';
import 'dart:convert';
import 'package:flutter_agent_pupau/chat_page/controllers/attachments_controller.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/models/attachment_model.dart';
import 'package:flutter_agent_pupau/services/language_service.dart';
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
    PupauChatController? chatController,
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
      return SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: url,
        header: {
          ...authParams,
          "Conversation-Token": conversationToken,
          "Content-type": "Application/json",
        },
        body: generateBody(message),
      );
    } catch (e) {
      return null;
    }
  }

  /// SSE (GET) for conversation history + catch-up.
  ///
  /// If the server returns 404, it means async execution is not enabled and
  /// callers should fall back to the REST pagination flow.
  static Future<Stream<SSEModel>?> createConversationSseGetStream(
    String assistantId,
    String conversationId,
    String conversationToken, {
    String? lastEventId,
    PupauChatController? chatController,
  }) async {
    try {
      // Getting authentication credentials from the config
      final Map<String, String>? authParams =
          chatController?.pupauConfig?.authHeaders;
      if (authParams == null) return null;

      // Generating query parameters (anonymous + customProperties).
      String queryParams = "";
      final List<String> params = [];
      if (chatController?.pupauConfig?.isAnonymous ?? false) {
        params.add(
          "encryptionPass=${PupauSharedPreferences.getAnonymousConversationKey()}",
        );
      }
      if (chatController?.pupauConfig?.customProperties != null) {
        params.add(
          "customProperties=${jsonEncode(chatController?.pupauConfig?.customProperties)}",
        );
      }
      if (params.isNotEmpty) {
        queryParams = "&${params.join('&')}";
      }

      final bool isMarketplace =
          chatController?.pupauConfig?.isMarketplace ?? false;

      final String url =
          "${ApiUrls.getQueryUrl(assistantId, conversationId, lastEventId: lastEventId, isMarketplace: isMarketplace)}$queryParams";

      // Probe the endpoint to reliably detect 404 (async SSE not enabled).
      //
      // We cannot get HTTP status from SSEClient.subscribeToSSE, so without a probe
      // we'd start an SSE stream that will silently retry on 404.
      try {
        final http.Client probeClient = http.Client();
        try {
          final http.Request req = http.Request('GET', Uri.parse(url));
          req.headers.addAll({
            ...authParams,
            "Conversation-Token": conversationToken,
            "Accept": "text/event-stream",
          });
          final http.StreamedResponse res = await probeClient
              .send(req)
              .timeout(const Duration(seconds: 2));
          if (res.statusCode == 404) return null;
        } finally {
          probeClient.close();
        }
      } catch (_) {
        // If probe fails (timeout/network), still attempt SSE subscription below.
      }

      return SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: url,
        header: {
          ...authParams,
          "Conversation-Token": conversationToken,
          "Accept": "text/event-stream",
        },
      );
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
    PupauChatController? chatController,
  }) async {
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
      language: chatController?.pupauConfig?.language,
    );
    if (request == null) return null;

    final StreamController<SSEModel> controller = StreamController<SSEModel>();
    request
        .send()
        .then((response) async {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            controller.addError(
              Exception("Audio SSE request failed: HTTP ${response.statusCode}"),
            );
            controller.close();
            return;
          }
          final contentType =
              response.headers['content-type']?.toLowerCase() ?? '';
          if (contentType.contains('application/json')) {
            try {
              final chunks = await response.stream.toList();
              final body = utf8.decode(chunks.expand((x) => x).toList());
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
        })
        .catchError((e, st) {
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
    PupauLanguage? language,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      // Form fields as in API example.
      request.fields['sse'] = 'true';
      request.fields['systemLang'] = language != null
          ? LanguageService.getCodeExtended(language)
          : "en-US";
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

      // Audio file with Content-Type: audio/mpeg.
      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          filename: filename,
          contentType: contentType,
        ),
      );

      final List<Attachment> attachments =
          Get.find<PupauAttachmentsController>().attachments
              .where((Attachment a) => a.selected)
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
    List<Attachment> attachments = Get.find<PupauAttachmentsController>()
        .attachments
        .where((Attachment attachment) => attachment.selected)
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
