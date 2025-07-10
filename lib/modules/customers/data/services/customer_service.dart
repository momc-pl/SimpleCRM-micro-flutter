import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/customers/data/models/customer_model.dart';
import 'package:simple_crm_flutter/modules/customers/data/models/customer_create_request.dart';
import 'package:simple_crm_flutter/modules/customers/data/models/customer_update_request.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class CustomerService extends BaseService {
  CustomerService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/customers';
  
  Future<ApiResponse<List<CustomerModel>>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? status,
    String? type,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      return await getList<CustomerModel>(
        queryParameters: queryParams,
        fromJson: (json) => CustomerModel.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('Failed to get customers: $e');
      return ApiResponse<List<CustomerModel>>.error('Failed to get customers: $e');
    }
  }
  
  Future<ApiResponse<CustomerModel>> getCustomerById(String id) async {
    return await getById<CustomerModel>(
      id: id,
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<CustomerModel>> createCustomer(CustomerCreateRequest request) async {
    return await create<CustomerModel>(
      data: request.toJson(),
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<CustomerModel>> updateCustomer(
    String id,
    CustomerUpdateRequest request,
  ) async {
    return await update<CustomerModel>(
      id: id,
      data: request.toJson(),
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<bool>> deleteCustomer(String id) async {
    return await delete(id: id);
  }
  
  Future<ApiResponse<List<CustomerModel>>> searchCustomers(String query) async {
    return await search<CustomerModel>(
      query: query,
      fromJson: (json) => CustomerModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<Map<String, dynamic>>> getCustomerStats() async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/stats',
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get customer stats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get customer stats: $e');
    }
  }
  
  Future<ApiResponse<List<CustomerModel>>> getRecentCustomers({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await apiService.get<List<CustomerModel>>(
        '$baseEndpoint/recent',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => CustomerModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get recent customers: $e');
      return ApiResponse<List<CustomerModel>>.error('Failed to get recent customers: $e');
    }
  }
  
  Future<ApiResponse<bool>> bulkDelete(List<String> ids) async {
    try {
      final response = await apiService.delete<bool>(
        '$baseEndpoint/bulk',
        queryParameters: {'ids': ids.join(',')},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to bulk delete customers: $e');
      return ApiResponse<bool>.error('Failed to bulk delete customers: $e');
    }
  }
  
  Future<ApiResponse<bool>> updateCustomerStatus(String id, String status) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$id/status',
        data: {'status': status},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update customer status: $e');
      return ApiResponse<bool>.error('Failed to update customer status: $e');
    }
  }
}