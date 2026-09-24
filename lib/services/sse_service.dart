import 'package:flutter_agent_pupau/config/pupau_agent_mode.dart';
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
import 'package:flutter_agent_pupau/models/pupau_living_agent_context.dart';

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

      final PupauAgentMode mode =
        chatController?.pupauConfig?.agentMode ?? PupauAgentMode.assistant;
      final bool isLivingAgent =
          chatController?.pupauConfig?.isLivingAgent ?? false;

      // Generating URL
      // A Living Agent turn posts to its own stream endpoint: the conversation
      // is not in the path (the backend creates it on the first message and
      // announces the id in the opening `la_thread` frame).
      String url = isLivingAgent
          ? ApiUrls.livingAgentChatStreamUrl(assistantId)
          : "${ApiUrls.sendQueryUrl(assistantId, conversationId, mode: mode)}$queryParams";

      final http.Client? customClient = chatController?.pupauConfig?.httpClient;
      final Map<String, String> header = {
        ...authParams,
        // Living Agent chat authenticates with the bearer alone - no
        // conversation token.
        if (!isLivingAgent) "Conversation-Token": conversationToken,
        "Content-type": "Application/json",
      };
      // Living Agent takes only `question` and, when continuing, the
      // conversation id - none of the assistant body's extra fields.
      // Taken, not read: the host attaches context to the turn that opens a
      // conversation, and it must not ride along on every later message.
      final PupauLivingAgentContext? livingAgentContext =
          isLivingAgent ? chatController?.takePendingLivingAgentContext() : null;

      final Map<String, dynamic> body = isLivingAgent
          ? <String, dynamic>{
              'question': message,
              if (conversationId.isNotEmpty) 'conversationId': conversationId,
              ...?livingAgentContext?.toBodyFields(),
            }
          : generateBody(message, chatController: chatController);

      // Host-supplied client (e.g. a private network tunnel) - flutter_client_sse
      // hardcodes its own internal client with no injection point, so this path
      // can't use it and instead parses the stream manually.
      if (customClient != null) {
        return _subscribeToSSEViaClient(
          client: customClient,
          method: SSERequestType.POST,
          url: url,
          header: header,
          body: body,
        );
      }

      // Creating SSE stream
      return SSEClient.subscribeToSSE(
        method: SSERequestType.POST,
        url: url,
        header: header,
        body: body,
      );
    } catch (_) {
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

      final PupauAgentMode mode =
        chatController?.pupauConfig?.agentMode ?? PupauAgentMode.assistant;
      // A Living Agent authenticates with the Bearer alone: it has no
      // conversation token, and sending an empty one is noise at best.
      final bool isLivingAgent = mode == PupauAgentMode.livingAgent;

      final String url =
          "${ApiUrls.getQueryUrl(assistantId, conversationId, lastEventId: lastEventId, mode: mode)}$queryParams";

      final http.Client? customClient = chatController?.pupauConfig?.httpClient;

      // Probe the endpoint to reliably detect 404 (async SSE not enabled).
      //
      // We cannot get HTTP status from SSEClient.subscribeToSSE, so without a probe
      // we'd start an SSE stream that will silently retry on 404.
      try {
        // Never close a host-supplied client - it's shared/owned by the host
        // (e.g. long-lived across every call while a private network tunnel
        // is active), unlike the plugin's own ephemeral fallback client.
        final http.Client probeClient = customClient ?? http.Client();
        try {
          final http.Request req = http.Request('GET', Uri.parse(url));
          req.headers.addAll({
            ...authParams,
            if (!isLivingAgent) "Conversation-Token": conversationToken,
            "Accept": "text/event-stream",
          });
          final http.StreamedResponse res = await probeClient
              .send(req)
              .timeout(const Duration(seconds: 2));
          if (res.statusCode == 404) return null;
        } finally {
          if (customClient == null) probeClient.close();
        }
      } catch (_) {
        // If probe fails (timeout/network), still attempt SSE subscription below.
      }

      final Map<String, String> header = {
        ...authParams,
        if (!isLivingAgent) "Conversation-Token": conversationToken,
        "Accept": "text/event-stream",
      };

      // Host-supplied client (e.g. a private network tunnel) - flutter_client_sse
      // hardcodes its own internal client with no injection point, so this path
      // can't use it and instead parses the stream manually.
      if (customClient != null) {
        return _subscribeToSSEViaClient(
          client: customClient,
          method: SSERequestType.GET,
          url: url,
          header: header,
        );
      }

      return SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: url,
        header: header,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<Stream<SSEModel>?> createSSEStreamAudio(
    String assistantId,
    String conversationId,
    String conversationToken,
    File audioFile, {
    bool isWebSearch = false,
    bool isVoiceMode = false,
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
    if (isVoiceMode) {
      params.add("voiceResponse=true");
      params.add("ttsFormat=pcm16");
      params.add("ttsSampleRate=24000");
      params.add("ttsAlignment=true");
    }
    if (params.isNotEmpty) {
      queryParams = "&${params.join('&')}";
    }

    final PupauAgentMode mode =
        chatController?.pupauConfig?.agentMode ?? PupauAgentMode.assistant;
    final bool isLivingAgent =
        chatController?.pupauConfig?.isLivingAgent ?? false;

    // Generating URL
    // The Living Agent voice endpoint takes the conversation as a form field,
    // not in the path, and none of the assistant query parameters.
    String url = isLivingAgent
        ? ApiUrls.livingAgentChatStreamAudioUrl(assistantId)
        : "${ApiUrls.sendAudioQueryUrl(assistantId, conversationId, mode: mode)}$queryParams";
    final request = await buildAudioMultipartRequest(
      url: url,
      audioFile: audioFile,
      isLivingAgent: isLivingAgent,
      livingAgentConversationId: conversationId,
      headers: {
        if (!isLivingAgent) "Conversation-Token": conversationToken,
        ...authParams,
        "Accept": "text/event-stream",
      },
      language: chatController?.pupauConfig?.language,
    );
    if (request == null) return null;

    // Never close a host-supplied client - it's shared/owned by the host.
    // request.send() (no args) would otherwise spin up its own ephemeral
    // client, bypassing any host-supplied one entirely.
    final http.Client? customClient = chatController?.pupauConfig?.httpClient;
    final http.Client client = customClient ?? http.Client();

    final StreamController<SSEModel> controller = StreamController<SSEModel>();
    void closeClientIfOwned() {
      if (customClient == null) client.close();
    }

    client
        .send(request)
        .then((response) async {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            controller.addError(
              Exception(
                "Audio SSE request failed: HTTP ${response.statusCode}",
              ),
            );
            controller.close();
            closeClientIfOwned();
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
            closeClientIfOwned();
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
              closeClientIfOwned();
            },
            onDone: () {
              controller.close();
              closeClientIfOwned();
            },
            cancelOnError: false,
          );
        })
        .catchError((e, st) {
          controller.addError(e);
          controller.close();
          closeClientIfOwned();
        });
    return Future<Stream<SSEModel>?>.value(controller.stream);
  }

  /// Builds multipart request matching API: sse, systemLang, customProperties, audio file (Content-Type: audio/mpeg).
  static Future<http.MultipartRequest?> buildAudioMultipartRequest({
    required String url,
    bool isLivingAgent = false,
    String livingAgentConversationId = '',
    required File audioFile,
    required Map<String, String> headers,
    PupauLanguage? language,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (isLivingAgent) {
        // Living Agent audio takes only the recording and, when continuing,
        // the conversation id.
        if (livingAgentConversationId.isNotEmpty) {
          request.fields['conversationId'] = livingAgentConversationId;
        }
        request.files.add(
          await http.MultipartFile.fromPath('audio', audioFile.path),
        );
        request.headers.addAll(headers);
        return request;
      }
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
    } catch (_) {
      return null;
    }
  }

  /// Subscribes to an SSE stream through a host-supplied [client] instead of
  /// `flutter_client_sse`'s `SSEClient.subscribeToSSE`, which hardcodes its
  /// own internal `http.Client()` with no way to inject a different one.
  ///
  /// Deliberately reimplements the same field-level parsing
  /// (`event:`/`data:`/`id:`) that library uses - NOT [_parseSSEStream]
  /// below, which is a simpler parser that always leaves `event`/`id` empty
  /// and would silently break real consumers of those fields (e.g.
  /// `ChatController` checks `sseEvent.event == 'history'` and persists
  /// `event.id` as the resume cursor for the next catch-up request).
  ///
  /// Unlike the library, this does not auto-retry on error - acceptable
  /// since this path only runs when a host explicitly supplies its own
  /// client (opt-in), and the caller already has its own stream
  /// error/done handling.
  static Stream<SSEModel> _subscribeToSSEViaClient({
    required http.Client client,
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    Map<String, dynamic>? body,
  }) {
    final StreamController<SSEModel> controller = StreamController<SSEModel>();
    final RegExp lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');

    Future<void> run() async {
      try {
        final http.Request request = http.Request(
          method == SSERequestType.GET ? 'GET' : 'POST',
          Uri.parse(url),
        );
        request.headers.addAll(header);
        if (body != null) {
          request.body = jsonEncode(body);
        }
        final http.StreamedResponse response = await client.send(request);
        if (response.statusCode < 200 || response.statusCode >= 300) {
          controller.addError(
            Exception('SSE request failed: HTTP ${response.statusCode}'),
          );
          await controller.close();
          return;
        }
        SSEModel currentModel = SSEModel(data: '', id: '', event: '');
        final Stream<String> lines = const LineSplitter().bind(
          utf8.decoder.bind(response.stream),
        );
        await for (final String line in lines) {
          if (line.isEmpty) {
            controller.add(currentModel);
            currentModel = SSEModel(data: '', id: '', event: '');
            continue;
          }
          final Match? match = lineRegex.firstMatch(line);
          final String? field = match?.group(1);
          if (field == null || field.isEmpty) continue;
          final String value = field == 'data'
              ? (line.length > 5 ? line.substring(5) : '')
              : (match?.group(2) ?? '');
          switch (field) {
            case 'event':
              currentModel.event = value;
              break;
            case 'data':
              currentModel.data = '${currentModel.data ?? ''}$value\n';
              break;
            case 'id':
              currentModel.id = value;
              break;
            default:
              break;
          }
        }
        await controller.close();
      } catch (e, st) {
        controller.addError(e, st);
        await controller.close();
      }
    }

    unawaited(run());
    return controller.stream;
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

  static Map<String, dynamic> generateBody(
    String message, {
    PupauChatController? chatController,
  }) {
    List<Attachment> attachments = Get.find<PupauAttachmentsController>()
        .attachments
        .where((Attachment attachment) => attachment.selected)
        .toList();
    final Map<String, dynamic> body = {
      "request": message,
      if (attachments.isNotEmpty)
        "attachments": attachments
            .map((attachment) => {"id": attachment.id, "mode": "STANDARD"})
            .toList(),
    };

    // Optional "thinking" params: only when the current model supports it and user enabled it.
    if (chatController != null &&
        chatController.isThinkingSupported() &&
        chatController.thinkingEnabled.value) {
      body["thinkingEnabled"] = true;
      final String? effort = chatController.thinkingEffortToSend();
      if (effort != null) {
        body["thinkingEffort"] = effort;
      }
    }

    return body;
  }
}
