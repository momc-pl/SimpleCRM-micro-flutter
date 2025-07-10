import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:simple_crm_flutter/core/config/api_config.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';
import 'package:simple_crm_flutter/core/network/exceptions/api_exception.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';

class ApiService {
  final Dio _dio;
  final Map<String, CancelToken> _cancelTokens = {};
  
  ApiService(this._dio) {
    _configureDio();
  }
  
  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'API-Version': ApiConfig.apiVersion,
      },
    );
    
    if (ApiConfig.isLoggingEnabled) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (log) => AppLogger.debug(log.toString()),
        ),
      );
    }
    
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }
  
  void _onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add request ID for tracking
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();
    options.headers['Request-ID'] = requestId;
    
    AppLogger.debug('🚀 REQUEST[$requestId]: ${options.method} ${options.path}');
    handler.next(options);
  }
  
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    final requestId = response.requestOptions.headers['Request-ID'];
    AppLogger.debug('✅ RESPONSE[$requestId]: ${response.statusCode}');
    handler.next(response);
  }
  
  void _onError(DioException err, ErrorInterceptorHandler handler) {
    final requestId = err.requestOptions.headers['Request-ID'];
    AppLogger.error('❌ ERROR[$requestId]: ${err.message}');
    
    final apiException = _handleError(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: apiException,
      message: apiException.message,
    ));
  }
  
  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          type: ApiExceptionType.timeout,
          statusCode: null,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        String message = 'An error occurred';
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          message = data['message'];
        }
        
        switch (statusCode) {
          case 400:
            return ApiException(
              message: message,
              type: ApiExceptionType.badRequest,
              statusCode: statusCode,
            );
          case 401:
            return ApiException(
              message: 'Authentication failed. Please login again.',
              type: ApiExceptionType.unauthorized,
              statusCode: statusCode,
            );
          case 403:
            return ApiException(
              message: 'Access denied. You don\'t have permission.',
              type: ApiExceptionType.forbidden,
              statusCode: statusCode,
            );
          case 404:
            return ApiException(
              message: 'Resource not found.',
              type: ApiExceptionType.notFound,
              statusCode: statusCode,
            );
          case 422:
            return ApiException(
              message: message,
              type: ApiExceptionType.validationError,
              statusCode: statusCode,
            );
          case 500:
            return ApiException(
              message: 'Server error. Please try again later.',
              type: ApiExceptionType.serverError,
              statusCode: statusCode,
            );
          default:
            return ApiException(
              message: message,
              type: ApiExceptionType.unknown,
              statusCode: statusCode,
            );
        }
      
      case DioExceptionType.cancel:
        return ApiException(
          message: 'Request was cancelled',
          type: ApiExceptionType.cancelled,
          statusCode: null,
        );
      
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return ApiException(
            message: 'No internet connection. Please check your network.',
            type: ApiExceptionType.noInternet,
            statusCode: null,
          );
        }
        return ApiException(
          message: 'An unexpected error occurred.',
          type: ApiExceptionType.unknown,
          statusCode: null,
        );
      
      default:
        return ApiException(
          message: 'An unexpected error occurred.',
          type: ApiExceptionType.unknown,
          statusCode: null,
        );
    }
  }
  
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
    String? cacheKey,
  }) async {
    return _executeWithRetry(
      () => _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
      cacheKey: cacheKey,
    );
  }
  
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }
  
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }
  
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? parser,
  }) async {
    return _executeWithRetry(
      () => _dio.delete<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      ),
      parser: parser,
    );
  }
  
  Future<ApiResponse<T>> _executeWithRetry<T>(
    Future<Response<Map<String, dynamic>>> Function() request, {
    T Function(dynamic data)? parser,
    String? cacheKey,
    int? maxRetries,
  }) async {
    maxRetries ??= ApiConfig.maxRetryAttempts;
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        final response = await request();
        
        if (response.data != null) {
          final apiResponse = ApiResponse<T>.fromJson(
            response.data!,
            parser: parser,
          );
          
          // Cache successful responses if cacheKey provided
          if (cacheKey != null && apiResponse.isSuccess) {
            // TODO: Implement caching mechanism
          }
          
          return apiResponse;
        }
        
        return ApiResponse<T>.error('Empty response from server');
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries) {
          if (e is DioException && e.error is ApiException) {
            final apiException = e.error as ApiException;
            return ApiResponse<T>.error(
              apiException.message,
              statusCode: apiException.statusCode,
            );
          }
          
          return ApiResponse<T>.error('Request failed after $maxRetries attempts');
        }
        
        // Wait before retry with exponential backoff
        final delay = Duration(milliseconds: 1000 * attempts);
        await Future.delayed(delay);
      }
    }
    
    return ApiResponse<T>.error('Request failed after $maxRetries attempts');
  }
  
  void cancelRequest(String requestId) {
    final cancelToken = _cancelTokens[requestId];
    if (cancelToken != null && !cancelToken.isCancelled) {
      cancelToken.cancel('Request cancelled by user');
      _cancelTokens.remove(requestId);
    }
  }
  
  void cancelAllRequests() {
    for (final cancelToken in _cancelTokens.values) {
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('All requests cancelled');
      }
    }
    _cancelTokens.clear();
  }
  
  void dispose() {
    cancelAllRequests();
    _dio.close();
  }
}