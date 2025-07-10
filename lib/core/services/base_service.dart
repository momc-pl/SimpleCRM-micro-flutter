import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

abstract class BaseService {
  final ApiService apiService;
  
  BaseService(this.apiService);
  
  String get baseEndpoint;
  
  Future<ApiResponse<List<T>>> getList<T>({
    Map<String, dynamic>? queryParameters,
    required T Function(Map<String, dynamic> json) fromJson,
    String? endpoint,
  }) async {
    try {
      final response = await apiService.get<List<T>>(
        endpoint ?? baseEndpoint,
        queryParameters: queryParameters,
        parser: (data) {
          if (data is List) {
            return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to fetch list from $baseEndpoint: $e');
      return ApiResponse<List<T>>.error('Failed to fetch data: $e');
    }
  }
  
  Future<ApiResponse<T>> getById<T>({
    required String id,
    required T Function(Map<String, dynamic> json) fromJson,
    String? endpoint,
  }) async {
    try {
      final response = await apiService.get<T>(
        '${endpoint ?? baseEndpoint}/$id',
        parser: (data) => fromJson(data as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to fetch item $id from $baseEndpoint: $e');
      return ApiResponse<T>.error('Failed to fetch item: $e');
    }
  }
  
  Future<ApiResponse<T>> create<T>({
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic> json) fromJson,
    String? endpoint,
  }) async {
    try {
      final response = await apiService.post<T>(
        endpoint ?? baseEndpoint,
        data: data,
        parser: (responseData) => fromJson(responseData as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to create item in $baseEndpoint: $e');
      return ApiResponse<T>.error('Failed to create item: $e');
    }
  }
  
  Future<ApiResponse<T>> update<T>({
    required String id,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic> json) fromJson,
    String? endpoint,
  }) async {
    try {
      final response = await apiService.put<T>(
        '${endpoint ?? baseEndpoint}/$id',
        data: data,
        parser: (responseData) => fromJson(responseData as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update item $id in $baseEndpoint: $e');
      return ApiResponse<T>.error('Failed to update item: $e');
    }
  }
  
  Future<ApiResponse<bool>> delete({
    required String id,
    String? endpoint,
  }) async {
    try {
      final response = await apiService.delete<bool>(
        '${endpoint ?? baseEndpoint}/$id',
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to delete item $id from $baseEndpoint: $e');
      return ApiResponse<bool>.error('Failed to delete item: $e');
    }
  }
  
  Future<ApiResponse<List<T>>> search<T>({
    required String query,
    required T Function(Map<String, dynamic> json) fromJson,
    Map<String, dynamic>? additionalParams,
    String? endpoint,
  }) async {
    try {
      final queryParams = {
        'q': query,
        ...?additionalParams,
      };
      
      final response = await apiService.get<List<T>>(
        '${endpoint ?? baseEndpoint}/search',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to search in $baseEndpoint: $e');
      return ApiResponse<List<T>>.error('Failed to search: $e');
    }
  }
}