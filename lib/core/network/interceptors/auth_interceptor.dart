import 'package:dio/dio.dart';
import 'package:simple_crm_flutter/core/storage/secure_storage.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;
  
  AuthInterceptor(this._secureStorage);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _secureStorage.getToken();
      
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        AppLogger.debug('Added Bearer token to request');
      }
      
      handler.next(options);
    } catch (e) {
      AppLogger.error('Failed to add auth token: $e');
      handler.next(options);
    }
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.debug('Response received: ${response.statusCode}');
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    AppLogger.error('Network error: ${err.message}');
    
    if (err.response?.statusCode == 401) {
      // Token expired, clear stored token
      await _secureStorage.deleteToken();
      AppLogger.info('Token expired, cleared stored token');
    }
    
    handler.next(err);
  }
}
