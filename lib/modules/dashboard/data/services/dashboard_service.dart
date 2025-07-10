import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/dashboard/data/models/dashboard_stats_model.dart';
import 'package:simple_crm_flutter/modules/dashboard/data/models/dashboard_chart_model.dart';
import 'package:simple_crm_flutter/modules/dashboard/data/models/dashboard_widget_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class DashboardService extends BaseService {
  DashboardService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/dashboard';
  
  Future<ApiResponse<DashboardStatsModel>> getDashboardStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      
      final response = await apiService.get<DashboardStatsModel>(
        '$baseEndpoint/stats',
        queryParameters: queryParams,
        parser: (data) => DashboardStatsModel.fromJson(data as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get dashboard stats: $e');
      return ApiResponse<DashboardStatsModel>.error('Failed to get dashboard stats: $e');
    }
  }
  
  Future<ApiResponse<List<DashboardChartModel>>> getDashboardCharts({
    String? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (type != null) queryParams['type'] = type;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      
      final response = await apiService.get<List<DashboardChartModel>>(
        '$baseEndpoint/charts',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => DashboardChartModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get dashboard charts: $e');
      return ApiResponse<List<DashboardChartModel>>.error('Failed to get dashboard charts: $e');
    }
  }
  
  Future<ApiResponse<List<DashboardWidgetModel>>> getDashboardWidgets({
    String? category,
    bool? active,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (category != null) queryParams['category'] = category;
      if (active != null) queryParams['active'] = active;
      
      final response = await apiService.get<List<DashboardWidgetModel>>(
        '$baseEndpoint/widgets',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => DashboardWidgetModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get dashboard widgets: $e');
      return ApiResponse<List<DashboardWidgetModel>>.error('Failed to get dashboard widgets: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getSalesPerformance({
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      if (groupBy != null) queryParams['group_by'] = groupBy;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/sales-performance',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get sales performance: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get sales performance: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getCustomerMetrics({
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/customer-metrics',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get customer metrics: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get customer metrics: $e');
    }
  }
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getRecentActivities({
    int? limit,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (limit != null) queryParams['limit'] = limit;
      if (type != null) queryParams['type'] = type;
      
      final response = await apiService.get<List<Map<String, dynamic>>>(
        '$baseEndpoint/recent-activities',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get recent activities: $e');
      return ApiResponse<List<Map<String, dynamic>>>.error('Failed to get recent activities: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getRevenueAnalysis({
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
    String? breakdown,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      if (breakdown != null) queryParams['breakdown'] = breakdown;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/revenue-analysis',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get revenue analysis: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get revenue analysis: $e');
    }
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getLeadConversionStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? period,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (period != null) queryParams['period'] = period;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/lead-conversion',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get lead conversion stats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get lead conversion stats: $e');
    }
  }
  
  Future<ApiResponse<List<Map<String, dynamic>>>> getTopPerformers({
    String? type,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (type != null) queryParams['type'] = type;
      if (limit != null) queryParams['limit'] = limit;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      
      final response = await apiService.get<List<Map<String, dynamic>>>(
        '$baseEndpoint/top-performers',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => item as Map<String, dynamic>).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get top performers: $e');
      return ApiResponse<List<Map<String, dynamic>>>.error('Failed to get top performers: $e');
    }
  }
}