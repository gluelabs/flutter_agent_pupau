import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/services/api_exceptions.dart';
import 'package:flutter_agent_pupau/services/pupau_event_service.dart';
import 'package:get/get.dart' hide Response;

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
  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(CustomInterceptors());

  // request timeout (default 10 seconds)
  static const int _timeoutInSeconds = 10;

  /// dio getter (used for testing)
  static Dio get dio => _dio;
  // Store *all* 401-failed calls (not just the latest one) so the host can
  // refresh token once and the plugin can retry/unblock everything.
  static final List<_RetryableApiCall> _failed401ApiCalls = <_RetryableApiCall>[];

  static bool get hasLatestFailedApiCall =>
      _failed401ApiCalls.isNotEmpty && _authRefreshCompleter == null;

  static String _callKey(_RetryableApiCall call) {
    final String headersKey =
        call.headers?.entries.map((e) => '${e.key}:${e.value}').join('|') ?? '';
    final String queryKey = call.queryParameters?.entries
            .map((e) => '${e.key}:${e.value}')
            .join('|') ??
        '';
    final String dataKey = call.data?.toString() ?? '';
    return '${call.requestType.name}::${call.url}::h=$headersKey::q=$queryKey::d=$dataKey';
  }

  static void _track401FailedCall(_RetryableApiCall call) {
    final String key = _callKey(call);
    final bool alreadyTracked = _failed401ApiCalls.any((c) => _callKey(c) == key);
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

  static Completer<void> _ensureAuthRefreshCycleStarted({
    required String url,
  }) {
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
      late Response response;
      if (requestType == RequestType.get) {
        response = await _dio.get(
          url,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      } else if (requestType == RequestType.post) {
        response = await _dio.post(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
      } else if (requestType == RequestType.put) {
        response = await _dio.put(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      } else if (requestType == RequestType.patch) {
        response = await _dio.patch(
          url,
          data: data,
          onReceiveProgress: onReceiveProgress,
          onSendProgress: onSendProgress,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      } else {
        response = await _dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: Options(headers: headers),
        );
      }
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
        final bool tokenUpdatedRecently = _lastAuthTokenUpdatedAt != null &&
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
  }) async {
    if (requestType == RequestType.get) {
      return await _dio.get(
        url,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    }
    if (requestType == RequestType.post) {
      return await _dio.post(
        url,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    }
    if (requestType == RequestType.put) {
      return await _dio.put(
        url,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    }
    if (requestType == RequestType.patch) {
      return await _dio.patch(
        url,
        data: data,
        onReceiveProgress: onReceiveProgress,
        onSendProgress: onSendProgress,
        queryParameters: queryParameters,
        options: Options(headers: headers),
        cancelToken: cancelToken,
      );
    }
    return await _dio.delete(
      url,
      data: data,
      queryParameters: queryParameters,
      options: Options(headers: headers),
      cancelToken: cancelToken,
    );
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
      await _dio.download(
        url,
        savePath,
        options: Options(
          receiveTimeout: const Duration(seconds: _timeoutInSeconds),
          sendTimeout: const Duration(seconds: _timeoutInSeconds),
        ),
        onReceiveProgress: onReceiveProgress,
      );
      onSuccess();
    } catch (error) {
      onError?.call(ApiException(url: url, message: "DOWNLOAD_EXCEPTION"));
    }
  }

  /// handle unexpected error
  static void _handleUnexpectedException({
    Function(ApiException error)? onError,
    required String url,
    required Object error,
  }) => onError?.call(ApiException(url: url, message: "UNEXPECTED_EXCEPTION"));

  /// handle timeout exception
  static void _handleTimeoutException({
    Function(ApiException error)? onError,
    required String url,
  }) => onError?.call(ApiException(url: url, message: "TIMEOUT_EXCEPTION"));

  /// handle timeout exception
  static void _handleSocketException({
    Function(ApiException error)? onError,
    required String url,
  }) => onError?.call(ApiException(url: url, message: "SOCKET_EXCEPTION"));

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
        payload: {
          "url": url,
          "statusCode": statusCode,
          "message": message,
        },
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
