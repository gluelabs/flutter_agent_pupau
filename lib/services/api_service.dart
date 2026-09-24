import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/services/api_exceptions.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:get/get.dart' hide Response;
import 'package:http/http.dart' as http;

enum RequestType { get, post, put, patch, delete }

class _RetryableApiCall {
  final String url;
  final RequestType requestType;
  final Map<String, dynamic>? headers;
  final Map<String, dynamic>? queryParameters;
  final dynamic data;

  const _RetryableApiCall({
    required this.url,
    required this.requestType,
    required this.headers,
    required this.queryParameters,
    required this.data,
  });
}

class ApiService {
  // safeApiCall previously had NO connect/receive/send timeout at all - a
  // hanging connection could hang indefinitely instead of failing with a
  // diagnosable error. Matches the same fix/reasoning applied host-side in
  // pupauapp's BaseClient.
  static const Duration _requestTimeout = Duration(seconds: 30);

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      connectTimeout: _requestTimeout,
      receiveTimeout: _requestTimeout,
      sendTimeout: _requestTimeout,
    ),
  )..interceptors.add(CustomInterceptors());

  // request timeout (default 10 seconds)
  static const int _timeoutInSeconds = 10;

  /// dio getter (used for testing)
  static Dio get dio => _dio;

  /// The host-supplied HTTP client override (see [PupauConfig.httpClient]),
  /// if any is currently configured - used instead of [_dio] for every
  /// request when set, so hosts with their own network routing (e.g. a
  /// private network tunnel) don't need the plugin to know anything about it.
  static http.Client? get _customClient {
    if (!Get.isRegistered<PupauChatController>()) return null;
    return Get.find<PupauChatController>().pupauConfig?.httpClient;
  }

  // Store *all* 401-failed calls (not just the latest one) so the host can
  // refresh token once and the plugin can retry/unblock everything.
  static final List<_RetryableApiCall> _failed401ApiCalls =
      <_RetryableApiCall>[];

  static bool get hasLatestFailedApiCall =>
      _failed401ApiCalls.isNotEmpty && _authRefreshCompleter == null;

  static String _callKey(_RetryableApiCall call) {
    final String headersKey =
        call.headers?.entries.map((e) => '${e.key}:${e.value}').join('|') ?? '';
    final String queryKey =
        call.queryParameters?.entries
            .map((e) => '${e.key}:${e.value}')
            .join('|') ??
        '';
    final String dataKey = call.data?.toString() ?? '';
    return '${call.requestType.name}::${call.url}::h=$headersKey::q=$queryKey::d=$dataKey';
  }

  static void _track401FailedCall(_RetryableApiCall call) {
    final String key = _callKey(call);
    final bool alreadyTracked = _failed401ApiCalls.any(
      (c) => _callKey(c) == key,
    );
    if (alreadyTracked) return;
    _failed401ApiCalls.add(call);
  }

  static void _untrack401FailedCall(_RetryableApiCall call) {
    final String key = _callKey(call);
    _failed401ApiCalls.removeWhere((c) => _callKey(c) == key);
  }

  // Shared auth refresh gate for multiple concurrent 401s.
  // First 401 starts a cycle (emits authError once); all other 401 calls wait
  // for host to update token; then each original request is retried once.
  static Completer<void>? _authRefreshCompleter;
  static const Duration _authRefreshWaitTimeout = Duration(seconds: 20);
  static DateTime? _lastAuthTokenUpdatedAt;

  static void notifyAuthTokenUpdated() {
    _lastAuthTokenUpdatedAt = DateTime.now();
    final completer = _authRefreshCompleter;
    if (completer == null) return;
    if (!completer.isCompleted) completer.complete();
    _authRefreshCompleter = null;
  }

  static Completer<void> _ensureAuthRefreshCycleStarted({required String url}) {
    if (_authRefreshCompleter != null) return _authRefreshCompleter!;
    _authRefreshCompleter = Completer<void>();
    _emitAuthErrorEvent(
      url: url,
      statusCode: 401,
      message: "AUTH_UNAUTHORIZED",
    );
    return _authRefreshCompleter!;
  }

  /// perform safe api request
  static Future<void> call(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    required Function(Response response) onSuccess,
    Function(ApiException error)? onError,
    Function(int value, int progress)? onReceiveProgress,
    Function(int total, int progress)?
    onSendProgress, // while sending (uploading) progress
    Function? onLoading,
    CancelToken? cancelToken,
    dynamic data,
  }) async {
    try {
      // 1) indicate loading state
      await onLoading?.call();
      // 2) try to perform http request
      final Response response = await _performRequest(
        url,
        requestType,
        headers: headers,
        queryParameters: queryParameters,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      await onSuccess(response);
    } on DioException catch (error) {
      final _RetryableApiCall retryable = _RetryableApiCall(
        url: url,
        requestType: requestType,
        headers: headers == null ? null : Map<String, dynamic>.from(headers),
        queryParameters: queryParameters == null
            ? null
            : Map<String, dynamic>.from(queryParameters),
        data: data,
      );
      final int? statusCode = error.response?.statusCode;
      if (statusCode == 401) {
        _track401FailedCall(retryable);
        // If the host already updated the token shortly before this late 401,
        // immediately retry once instead of waiting for another refresh.
        final bool hasActiveGate = _authRefreshCompleter != null;
        final bool tokenUpdatedRecently =
            _lastAuthTokenUpdatedAt != null &&
            DateTime.now().difference(_lastAuthTokenUpdatedAt!) <
                _authRefreshWaitTimeout;

        if (!hasActiveGate && tokenUpdatedRecently) {
          try {
            final Response retryResponse = await _executeRequestForRetry(
              url,
              requestType,
              headers: headers,
              queryParameters: queryParameters,
              data: data,
              onReceiveProgress: onReceiveProgress,
              onSendProgress: onSendProgress,
              cancelToken: cancelToken,
            );
            _untrack401FailedCall(retryable);
            await onSuccess(retryResponse);
            return;
          } on DioException catch (lateError) {
            final int? lateStatusCode = lateError.response?.statusCode;
            if (lateStatusCode == 401) {
              // Token is still not accepted; fall back to the normal gate
              // flow (which will emit a new authError cycle if needed).
            } else {
              _handleDioError(error: lateError, url: url, onError: onError);
              return;
            }
          }
        }

        await _handleAuth401AndRetry(
          error: error,
          url: url,
          requestType: requestType,
          headers: headers,
          queryParameters: queryParameters,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          cancelToken: cancelToken,
          onSuccess: onSuccess,
          onError: onError,
          trackedCall: retryable,
        );
        return;
      }
      _handleDioError(error: error, url: url, onError: onError);
    } on SocketException {
      _handleSocketException(url: url, onError: onError);
    } on TimeoutException {
      _handleTimeoutException(url: url, onError: onError);
    } catch (error) {
      _handleUnexpectedException(url: url, onError: onError, error: error);
    }
  }

  static Future<Response> _executeRequestForRetry(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Function(int value, int progress)? onReceiveProgress,
    dynamic onSendProgress,
    CancelToken? cancelToken,
  }) => _performRequest(
    url,
    requestType,
    headers: headers,
    queryParameters: queryParameters,
    data: data,
    onReceiveProgress: onReceiveProgress,
    onSendProgress: onSendProgress,
    cancelToken: cancelToken,
  );

  /// Performs the actual request, either through [_dio] (default) or through
  /// the host-supplied [PupauConfig.httpClient] override when one is set -
  /// shared by [call]'s initial attempt and [_executeRequestForRetry] so all
  /// the surrounding 401/retry/error-handling logic stays identical
  /// regardless of which transport performs the call.
  static Future<Response> _performRequest(
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Function(int value, int progress)? onReceiveProgress,
    dynamic onSendProgress,
    CancelToken? cancelToken,
  }) {
    final http.Client? client = _customClient;
    if (client != null) {
      return _performClientRequest(
        client,
        url,
        requestType,
        headers: headers,
        queryParameters: queryParameters,
        data: data,
      );
    }
    switch (requestType) {
      case RequestType.get:
        return _dio.get(
          url,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      case RequestType.post:
        return _dio.post(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      case RequestType.put:
        return _dio.put(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      case RequestType.patch:
        return _dio.patch(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      case RequestType.delete:
        return _dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
    }
  }

  /// Performs the request through [client] instead of [_dio], converting the
  /// [http.Response] into the same [Response] shape the rest of ApiService
  /// already expects. Every failure mode (bad status, timeout, any other
  /// exception) is normalized into a [DioException] so this path is
  /// indistinguishable from Dio's own contract to every existing catch site
  /// in this file - mirrors pupauapp's BaseClient._tailnetRequest.
  static Future<Response> _performClientRequest(
    http.Client client,
    String url,
    RequestType requestType, {
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic data,
  }) async {
    final RequestOptions requestOptions = RequestOptions(path: url);
    try {
      Uri uri = Uri.parse(url);
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(
          queryParameters: {
            ...uri.queryParameters,
            ...queryParameters.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          },
        );
      }
      // This path bypasses ApiService's Dio [CustomInterceptors], which is
      // where Api-Key/Authorization normally gets injected for every Dio
      // request - so auth headers have to be added explicitly here too,
      // via the same [PupauConfig.authHeaders] CustomInterceptors uses.
      final PupauConfig? config = Get.isRegistered<PupauChatController>()
          ? Get.find<PupauChatController>().pupauConfig
          : null;
      final Map<String, String> requestHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...?config?.authHeaders,
        ...?headers?.map((key, value) => MapEntry(key, value.toString())),
      };
      final String? body = data != null ? jsonEncode(data) : null;
      final http.Response httpResponse = await switch (requestType) {
        RequestType.get => client.get(uri, headers: requestHeaders),
        RequestType.post => client.post(
          uri,
          headers: requestHeaders,
          body: body,
        ),
        RequestType.put => client.put(uri, headers: requestHeaders, body: body),
        RequestType.patch => client.patch(
          uri,
          headers: requestHeaders,
          body: body,
        ),
        RequestType.delete => client.delete(
          uri,
          headers: requestHeaders,
          body: body,
        ),
      }.timeout(_requestTimeout);

      final dynamic decodedBody = httpResponse.body.isNotEmpty
          ? jsonDecode(httpResponse.body)
          : null;
      final Response dioResponse = Response(
        requestOptions: requestOptions,
        data: decodedBody,
        statusCode: httpResponse.statusCode,
        statusMessage: httpResponse.reasonPhrase,
      );
      if (httpResponse.statusCode < 200 || httpResponse.statusCode >= 300) {
        throw DioException(
          requestOptions: requestOptions,
          response: dioResponse,
          type: DioExceptionType.badResponse,
          message: 'HTTP ${httpResponse.statusCode}',
        );
      }
      return dioResponse;
    } on DioException {
      rethrow;
    } on TimeoutException catch (e) {
      throw DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
        error: e,
      );
    } catch (e) {
      throw DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
        error: e,
      );
    }
  }

  static Future<void> _handleAuth401AndRetry({
    required DioException error,
    required String url,
    required RequestType requestType,
    required Map<String, dynamic>? headers,
    required Map<String, dynamic>? queryParameters,
    required dynamic data,
    required Function(int value, int progress)? onReceiveProgress,
    required dynamic onSendProgress,
    required CancelToken? cancelToken,
    required Function(Response response) onSuccess,
    required Function(ApiException error)? onError,
    required _RetryableApiCall trackedCall,
  }) async {
    final completer = _ensureAuthRefreshCycleStarted(url: url);
    try {
      await completer.future.timeout(_authRefreshWaitTimeout);
    } on TimeoutException {
      _authRefreshCompleter = null;
      _handleDioError(error: error, url: url, onError: onError);
      return;
    }

    try {
      final Response retryResponse = await _executeRequestForRetry(
        url,
        requestType,
        headers: headers,
        queryParameters: queryParameters,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
      _untrack401FailedCall(trackedCall);
      await onSuccess(retryResponse);
    } on DioException catch (secondError) {
      final int? secondStatusCode = secondError.response?.statusCode;
      if (secondStatusCode == 401) {
        _ensureAuthRefreshCycleStarted(url: url);
      }
      _handleDioError(error: secondError, url: url, onError: onError);
    } on SocketException {
      _handleSocketException(url: url, onError: onError);
    } on TimeoutException {
      _handleTimeoutException(url: url, onError: onError);
    } catch (e) {
      _handleUnexpectedException(url: url, onError: onError, error: e);
    }
  }

  /// Retries the latest failed API call using current auth context.
  ///
  /// This is useful after host app refreshes login/token.
  static Future<Response?> retryLatestFailedApiCall() async {
    // Legacy retry is suppressed while the shared auth refresh gate is active.
    // This prevents conflicts with the new host-driven `updateAuthToken(...)` flow.
    if (_authRefreshCompleter != null) return null;
    if (_failed401ApiCalls.isEmpty) return null;
    final _RetryableApiCall latest = _failed401ApiCalls.last;

    late Response response;
    if (latest.requestType == RequestType.get) {
      response = await _dio.get(
        latest.url,
        queryParameters: latest.queryParameters,
        options: Options(headers: latest.headers),
      );
    } else if (latest.requestType == RequestType.post) {
      response = await _dio.post(
        latest.url,
        data: latest.data,
        queryParameters: latest.queryParameters,
        options: Options(headers: latest.headers),
      );
    } else if (latest.requestType == RequestType.put) {
      response = await _dio.put(
        latest.url,
        data: latest.data,
        queryParameters: latest.queryParameters,
        options: Options(headers: latest.headers),
      );
    } else if (latest.requestType == RequestType.patch) {
      response = await _dio.patch(
        latest.url,
        data: latest.data,
        queryParameters: latest.queryParameters,
        options: Options(headers: latest.headers),
      );
    } else {
      response = await _dio.delete(
        latest.url,
        data: latest.data,
        queryParameters: latest.queryParameters,
        options: Options(headers: latest.headers),
      );
    }

    _untrack401FailedCall(latest);
    return response;
  }

  /// download file
  static Future<void> download({
    required String url,
    required String savePath,
    Function(ApiException error)? onError,
    Function(int value, int progress)? onReceiveProgress,
    required Function onSuccess,
  }) async {
    try {
      final http.Client? client = _customClient;
      if (client != null) {
        await _downloadViaClient(
          client,
          url: url,
          savePath: savePath,
          onReceiveProgress: onReceiveProgress,
        );
      } else {
        await _dio.download(
          url,
          savePath,
          options: Options(
            receiveTimeout: const Duration(seconds: _timeoutInSeconds),
            sendTimeout: const Duration(seconds: _timeoutInSeconds),
          ),
          onReceiveProgress: onReceiveProgress,
        );
      }
      onSuccess();
    } catch (error) {
      onError?.call(ApiException(url: url, message: "DOWNLOAD_EXCEPTION"));
    }
  }

  /// Downloads through the host-supplied [client] instead of [_dio] - same
  /// reasoning as [_performClientRequest].
  static Future<void> _downloadViaClient(
    http.Client client, {
    required String url,
    required String savePath,
    Function(int value, int progress)? onReceiveProgress,
  }) async {
    final PupauConfig? config = Get.isRegistered<PupauChatController>()
        ? Get.find<PupauChatController>().pupauConfig
        : null;
    final http.Request request = http.Request('GET', Uri.parse(url));
    if (config?.authHeaders != null) {
      request.headers.addAll(config!.authHeaders!);
    }
    final http.StreamedResponse response = await client
        .send(request)
        .timeout(_requestTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final int total = response.contentLength ?? 0;
    int received = 0;
    final IOSink sink = File(savePath).openWrite();
    try {
      await for (final List<int> chunk in response.stream) {
        received += chunk.length;
        sink.add(chunk);
        onReceiveProgress?.call(received, total);
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  /// handle unexpected error
  static void _handleUnexpectedException({
    Function(ApiException error)? onError,
    required String url,
    required Object error,
  }) {
    onError?.call(ApiException(url: url, message: "UNEXPECTED_EXCEPTION"));
  }

  /// handle timeout exception
  static void _handleTimeoutException({
    Function(ApiException error)? onError,
    required String url,
  }) {
    onError?.call(ApiException(url: url, message: "TIMEOUT_EXCEPTION"));
  }

  /// handle timeout exception
  static void _handleSocketException({
    Function(ApiException error)? onError,
    required String url,
  }) {
    onError?.call(ApiException(url: url, message: "SOCKET_EXCEPTION"));
  }

  /// handle Dio error
  static void _handleDioError({
    required DioException error,
    Function(ApiException error)? onError,
    required String url,
  }) {
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      if (statusCode >= 400 && statusCode < 500) {
        onError?.call(
          ApiException(
            url: url,
            statusCode: statusCode,
            response: error.response,
            message: "CLIENT_ERROR",
          ),
        );
      } else if (statusCode >= 500) {
        onError?.call(
          ApiException(
            url: url,
            statusCode: statusCode,
            response: error.response,
            message: "SERVER_ERROR",
          ),
        );
      } else {
        onError?.call(
          ApiException(
            url: url,
            statusCode: statusCode,
            response: error.response,
            message: "DIO_EXCEPTION",
          ),
        );
      }
    } else {
      onError?.call(
        ApiException(
          url: url,
          statusCode: statusCode,
          response: error.response,
          message: "DIO_EXCEPTION",
        ),
      );
    }
  }

  static void _emitAuthErrorEvent({
    required String url,
    required int? statusCode,
    required String message,
  }) {
    PupauEventService.instance.emitPupauEvent(
      PupauEvent(
        type: UpdateConversationType.authError,
        payload: {"url": url, "statusCode": statusCode, "message": message},
      ),
    );
  }
}

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (Get.isRegistered<PupauChatController>()) {
      final PupauConfig? config = Get.find<PupauChatController>().pupauConfig;
      options.headers = Map<String, dynamic>.from(options.headers);
      if (config?.apiKey != null && config!.apiKey!.isNotEmpty) {
        options.headers["Api-Key"] = config.apiKey;
      } else if (config?.bearerToken != null &&
          config!.bearerToken!.isNotEmpty) {
        options.headers["Authorization"] = "Bearer ${config.bearerToken}";
      }
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) =>
      handler.next(err);
}
