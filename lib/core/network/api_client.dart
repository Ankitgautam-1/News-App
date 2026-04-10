import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:news_app/core/constants/app_constants.dart';

/// API Client configuration using Dio
///
/// Handles:
/// - Base URL and timeout configurations
/// - Logging interceptor for debugging
/// - Error handling and response transformation
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  late Dio _dio;

  ApiClient._internal() {
    _initializeDio();
  }

  factory ApiClient() {
    return _instance;
  }

  /// Initialize Dio with configurations
  void _initializeDio() {
    final baseOptions = BaseOptions(
      baseUrl: AppConstants.newsApiBaseUrl,
      connectTimeout: const Duration(seconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
      sendTimeout: const Duration(seconds: AppConstants.sendTimeout),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    _dio = Dio(baseOptions);

    // Add logging interceptor for debugging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (Object object) {
          log(object.toString());
        },
      ),
    );

    // Add custom interceptor for error handling
    _dio.interceptors.add(_ErrorInterceptor());
  }

  /// Get the Dio instance for making requests
  Dio get dio => _dio;

  /// Get method
  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get(
      endpoint,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Post method
  Future<Response> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Put method
  Future<Response> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Delete method
  Future<Response> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

/// Custom interceptor for handling errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add API key to all requests
    if (AppConstants.newsApiKey.isEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          message:
              'Missing NEWS_API_KEY. Run with --dart-define=NEWS_API_KEY=your_key_here',
        ),
      );
      return;
    }
    options.queryParameters[AppConstants.apiKeyQueryParam] = AppConstants.newsApiKey;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
  }
}
