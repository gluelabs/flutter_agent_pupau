import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_agent_pupau/chat_page/controllers/chat_controller.dart';
import 'package:flutter_agent_pupau/config/pupau_config.dart';
import 'package:flutter_agent_pupau/services/api_exceptions.dart';
import 'package:get/get.dart' hide Response;

enum RequestType { get, post, put, patch, delete }

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
      _handleDioError(error: error, url: url, onError: onError);
    } on SocketException {
      _handleSocketException(url: url, onError: onError);
    } on TimeoutException {
      _handleTimeoutException(url: url, onError: onError);
    } catch (error) {
      _handleUnexpectedException(url: url, onError: onError, error: error);
    }
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
}

class CustomInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (Get.isRegistered<ChatController>()) {
      final PupauConfig? config = Get.find<ChatController>().pupauConfig;
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
