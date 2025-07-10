import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/sales/data/models/sale_model.dart';
import 'package:simple_crm_flutter/modules/sales/data/models/sale_create_request.dart';
import 'package:simple_crm_flutter/modules/sales/data/models/sale_update_request.dart';
import 'package:simple_crm_flutter/modules/sales/data/models/pipeline_model.dart';
import 'package:simple_crm_flutter/modules/sales/data/models/pipeline_stage_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class SalesService extends BaseService {
  SalesService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/sales';
  
  // Sales CRUD operations
  Future<ApiResponse<List<SaleModel>>> getSales({
    int? page,
    int? limit,
    String? search,
    String? customerId,
    String? stage,
    String? status,
    String? assignedTo,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (stage != null) queryParams['stage'] = stage;
      if (status != null) queryParams['status'] = status;
      if (assignedTo != null) queryParams['assigned_to'] = assignedTo;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      return await getList<SaleModel>(
        queryParameters: queryParams,
        fromJson: (json) => SaleModel.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('Failed to get sales: $e');
      return ApiResponse<List<SaleModel>>.error('Failed to get sales: $e');
    }
  }
  
  Future<ApiResponse<SaleModel>> getSaleById(String id) async {
    return await getById<SaleModel>(
      id: id,
      fromJson: (json) => SaleModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<SaleModel>> createSale(SaleCreateRequest request) async {
    return await create<SaleModel>(
      data: request.toJson(),
      fromJson: (json) => SaleModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<SaleModel>> updateSale(
    String id,
    SaleUpdateRequest request,
  ) async {
    return await update<SaleModel>(
      id: id,
      data: request.toJson(),
      fromJson: (json) => SaleModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<bool>> deleteSale(String id) async {
    return await delete(id: id);
  }
  
  // Pipeline operations
  Future<ApiResponse<List<PipelineModel>>> getPipelines() async {
    try {
      final response = await apiService.get<List<PipelineModel>>(
        '/sales/pipelines',
        parser: (data) {
          if (data is List) {
            return data.map((item) => PipelineModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get pipelines: $e');
      return ApiResponse<List<PipelineModel>>.error('Failed to get pipelines: $e');
    }
  }
  
  Future<ApiResponse<PipelineModel>> getPipelineById(String id) async {
    try {
      final response = await apiService.get<PipelineModel>(
        '/sales/pipelines/$id',
        parser: (data) => PipelineModel.fromJson(data as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get pipeline $id: $e');
      return ApiResponse<PipelineModel>.error('Failed to get pipeline: $e');
    }
  }
  
  Future<ApiResponse<List<PipelineStageModel>>> getPipelineStages(String pipelineId) async {
    try {
      final response = await apiService.get<List<PipelineStageModel>>(
        '/sales/pipelines/$pipelineId/stages',
        parser: (data) {
          if (data is List) {
            return data.map((item) => PipelineStageModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get pipeline stages: $e');
      return ApiResponse<List<PipelineStageModel>>.error('Failed to get pipeline stages: $e');
    }
  }
  
  Future<ApiResponse<bool>> moveSaleToStage(String saleId, String stageId) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$saleId/stage',
        data: {'stage_id': stageId},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to move sale to stage: $e');
      return ApiResponse<bool>.error('Failed to move sale to stage: $e');
    }
  }
  
  // Sales Analytics
  Future<ApiResponse<Map<String, dynamic>>> getSalesStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? groupBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (groupBy != null) queryParams['group_by'] = groupBy;
      
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/stats',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get sales stats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get sales stats: $e');
    }
  }
  
  Future<ApiResponse<List<SaleModel>>> getRecentSales({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await apiService.get<List<SaleModel>>(
        '$baseEndpoint/recent',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => SaleModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get recent sales: $e');
      return ApiResponse<List<SaleModel>>.error('Failed to get recent sales: $e');
    }
  }
  
  Future<ApiResponse<List<SaleModel>>> getSalesByCustomer(String customerId) async {
    try {
      final response = await apiService.get<List<SaleModel>>(
        '/customers/$customerId/sales',
        parser: (data) {
          if (data is List) {
            return data.map((item) => SaleModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get sales for customer $customerId: $e');
      return ApiResponse<List<SaleModel>>.error('Failed to get sales for customer: $e');
    }
  }
  
  Future<ApiResponse<bool>> assignSale(String saleId, String userId) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$saleId/assign',
        data: {'user_id': userId},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to assign sale: $e');
      return ApiResponse<bool>.error('Failed to assign sale: $e');
    }
  }
  
  Future<ApiResponse<bool>> updateSaleStatus(String saleId, String status) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$saleId/status',
        data: {'status': status},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update sale status: $e');
      return ApiResponse<bool>.error('Failed to update sale status: $e');
    }
  }
}