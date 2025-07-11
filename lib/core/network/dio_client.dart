import 'package:dio/dio.dart';
import 'package:simple_crm_flutter/core/constants/api_constants.dart';
import 'package:simple_crm_flutter/core/config/api_config.dart';
import 'package:simple_crm_flutter/core/network/interceptors/auth_interceptor.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class DioClient {
  final Dio _dio;
  
  DioClient(this._dio) {
    _initializeClient();
  }
  
  void _initializeClient() {
    _dio.options = BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Version': ApiConstants.apiVersion,
      },
    );
    
    // Add auth interceptor first (will be injected via DI)
    // _dio.interceptors.add(AuthInterceptor());
    
    // Add logging interceptor only in debug mode
    if (ApiConfig.isLoggingEnabled) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (log) => AppLogger.debug(log.toString()),
        ),
      );
    }
    
    // Add retry interceptor for microservices resilience
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            AppLogger.warning('Retrying request due to: ${error.message}');
            try {
              final response = await _retry(error.requestOptions);
              handler.resolve(response);
            } catch (e) {
              handler.next(error);
            }
          } else {
            handler.next(error);
          }
        },
      ),
    );
  }
  
  void addAuthInterceptor(AuthInterceptor authInterceptor) {
    // Remove existing auth interceptors
    _dio.interceptors.removeWhere((interceptor) => interceptor is AuthInterceptor);
    // Add new auth interceptor at the beginning
    _dio.interceptors.insert(0, authInterceptor);
  }
  
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500);
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final retryDio = Dio();
    retryDio.options = _dio.options;
    return await retryDio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
    );
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.error('GET request failed: $e');
      rethrow;
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.error('POST request failed: $e');
      rethrow;
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.error('PUT request failed: $e');
      rethrow;
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      AppLogger.error('DELETE request failed: $e');
      rethrow;
    }
  }
}
