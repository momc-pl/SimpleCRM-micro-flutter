import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/orders/data/models/order_model.dart';
import 'package:simple_crm_flutter/modules/orders/data/models/order_create_request.dart';
import 'package:simple_crm_flutter/modules/orders/data/models/order_update_request.dart';
import 'package:simple_crm_flutter/modules/orders/data/models/order_item_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class OrderService extends BaseService {
  OrderService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/orders';
  
  Future<ApiResponse<List<OrderModel>>> getOrders({
    int? page,
    int? limit,
    String? search,
    String? customerId,
    String? status,
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
      if (status != null) queryParams['status'] = status;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      return await getList<OrderModel>(
        queryParameters: queryParams,
        fromJson: (json) => OrderModel.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('Failed to get orders: $e');
      return ApiResponse<List<OrderModel>>.error('Failed to get orders: $e');
    }
  }
  
  Future<ApiResponse<OrderModel>> getOrderById(String id) async {
    return await getById<OrderModel>(
      id: id,
      fromJson: (json) => OrderModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<OrderModel>> createOrder(OrderCreateRequest request) async {
    return await create<OrderModel>(
      data: request.toJson(),
      fromJson: (json) => OrderModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<OrderModel>> updateOrder(
    String id,
    OrderUpdateRequest request,
  ) async {
    return await update<OrderModel>(
      id: id,
      data: request.toJson(),
      fromJson: (json) => OrderModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<bool>> deleteOrder(String id) async {
    return await delete(id: id);
  }
  
  Future<ApiResponse<List<OrderModel>>> searchOrders(String query) async {
    return await search<OrderModel>(
      query: query,
      fromJson: (json) => OrderModel.fromJson(json),
    );
  }
  
  // Order Items Management
  Future<ApiResponse<List<OrderItemModel>>> getOrderItems(String orderId) async {
    try {
      final response = await apiService.get<List<OrderItemModel>>(
        '$baseEndpoint/$orderId/items',
        parser: (data) {
          if (data is List) {
            return data.map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get order items: $e');
      return ApiResponse<List<OrderItemModel>>.error('Failed to get order items: $e');
    }
  }
  
  Future<ApiResponse<OrderItemModel>> addOrderItem(String orderId, Map<String, dynamic> itemData) async {
    try {
      final response = await apiService.post<OrderItemModel>(
        '$baseEndpoint/$orderId/items',
        data: itemData,
        parser: (responseData) => OrderItemModel.fromJson(responseData as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to add order item: $e');
      return ApiResponse<OrderItemModel>.error('Failed to add order item: $e');
    }
  }
  
  Future<ApiResponse<OrderItemModel>> updateOrderItem(
    String orderId,
    String itemId,
    Map<String, dynamic> itemData,
  ) async {
    try {
      final response = await apiService.put<OrderItemModel>(
        '$baseEndpoint/$orderId/items/$itemId',
        data: itemData,
        parser: (responseData) => OrderItemModel.fromJson(responseData as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update order item: $e');
      return ApiResponse<OrderItemModel>.error('Failed to update order item: $e');
    }
  }
  
  Future<ApiResponse<bool>> removeOrderItem(String orderId, String itemId) async {
    try {
      final response = await apiService.delete<bool>(
        '$baseEndpoint/$orderId/items/$itemId',
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to remove order item: $e');
      return ApiResponse<bool>.error('Failed to remove order item: $e');
    }
  }
  
  // Order Status Management
  Future<ApiResponse<bool>> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$orderId/status',
        data: {'status': status},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update order status: $e');
      return ApiResponse<bool>.error('Failed to update order status: $e');
    }
  }
  
  Future<ApiResponse<bool>> cancelOrder(String orderId, String reason) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$orderId/cancel',
        data: {'reason': reason},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to cancel order: $e');
      return ApiResponse<bool>.error('Failed to cancel order: $e');
    }
  }
  
  Future<ApiResponse<bool>> fulfillOrder(String orderId) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$orderId/fulfill',
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to fulfill order: $e');
      return ApiResponse<bool>.error('Failed to fulfill order: $e');
    }
  }
  
  // Order Analytics
  Future<ApiResponse<Map<String, dynamic>>> getOrderStats({
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
        '$baseEndpoint/stats',
        queryParameters: queryParams,
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get order stats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get order stats: $e');
    }
  }
  
  Future<ApiResponse<List<OrderModel>>> getOrdersByCustomer(String customerId) async {
    try {
      final response = await apiService.get<List<OrderModel>>(
        '/customers/$customerId/orders',
        parser: (data) {
          if (data is List) {
            return data.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get orders for customer $customerId: $e');
      return ApiResponse<List<OrderModel>>.error('Failed to get orders for customer: $e');
    }
  }
  
  Future<ApiResponse<List<OrderModel>>> getRecentOrders({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await apiService.get<List<OrderModel>>(
        '$baseEndpoint/recent',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get recent orders: $e');
      return ApiResponse<List<OrderModel>>.error('Failed to get recent orders: $e');
    }
  }
  
  Future<ApiResponse<List<OrderModel>>> getPendingOrders({int? limit}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      
      final response = await apiService.get<List<OrderModel>>(
        '$baseEndpoint/pending',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get pending orders: $e');
      return ApiResponse<List<OrderModel>>.error('Failed to get pending orders: $e');
    }
  }
  
  Future<ApiResponse<bool>> bulkUpdateOrderStatus(List<String> orderIds, String status) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/bulk-status',
        data: {
          'order_ids': orderIds,
          'status': status,
        },
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to bulk update order status: $e');
      return ApiResponse<bool>.error('Failed to bulk update order status: $e');
    }
  }
}