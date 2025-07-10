import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/products/data/models/product_model.dart';
import 'package:simple_crm_flutter/modules/products/data/models/product_create_request.dart';
import 'package:simple_crm_flutter/modules/products/data/models/product_update_request.dart';
import 'package:simple_crm_flutter/modules/products/data/models/product_category_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class ProductService extends BaseService {
  ProductService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/products';
  
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int? page,
    int? limit,
    String? search,
    String? category,
    String? status,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (minPrice != null) queryParams['min_price'] = minPrice;
      if (maxPrice != null) queryParams['max_price'] = maxPrice;
      if (inStock != null) queryParams['in_stock'] = inStock;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      return await getList<ProductModel>(
        queryParameters: queryParams,
        fromJson: (json) => ProductModel.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('Failed to get products: $e');
      return ApiResponse<List<ProductModel>>.error('Failed to get products: $e');
    }
  }
  
  Future<ApiResponse<ProductModel>> getProductById(String id) async {
    return await getById<ProductModel>(
      id: id,
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<ProductModel>> createProduct(ProductCreateRequest request) async {
    return await create<ProductModel>(
      data: request.toJson(),
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<ProductModel>> updateProduct(
    String id,
    ProductUpdateRequest request,
  ) async {
    return await update<ProductModel>(
      id: id,
      data: request.toJson(),
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<bool>> deleteProduct(String id) async {
    return await delete(id: id);
  }
  
  Future<ApiResponse<List<ProductModel>>> searchProducts(String query) async {
    return await search<ProductModel>(
      query: query,
      fromJson: (json) => ProductModel.fromJson(json),
    );
  }
  
  // Product Categories
  Future<ApiResponse<List<ProductCategoryModel>>> getProductCategories() async {
    try {
      final response = await apiService.get<List<ProductCategoryModel>>(
        '$baseEndpoint/categories',
        parser: (data) {
          if (data is List) {
            return data.map((item) => ProductCategoryModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get product categories: $e');
      return ApiResponse<List<ProductCategoryModel>>.error('Failed to get product categories: $e');
    }
  }
  
  Future<ApiResponse<ProductCategoryModel>> createProductCategory(Map<String, dynamic> data) async {
    try {
      final response = await apiService.post<ProductCategoryModel>(
        '$baseEndpoint/categories',
        data: data,
        parser: (responseData) => ProductCategoryModel.fromJson(responseData as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to create product category: $e');
      return ApiResponse<ProductCategoryModel>.error('Failed to create product category: $e');
    }
  }
  
  // Inventory Management
  Future<ApiResponse<bool>> updateProductStock(String id, int quantity) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$id/stock',
        data: {'quantity': quantity},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update product stock: $e');
      return ApiResponse<bool>.error('Failed to update product stock: $e');
    }
  }
  
  Future<ApiResponse<bool>> adjustProductStock(String id, int adjustment, String reason) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$id/stock/adjust',
        data: {
          'adjustment': adjustment,
          'reason': reason,
        },
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to adjust product stock: $e');
      return ApiResponse<bool>.error('Failed to adjust product stock: $e');
    }
  }
  
  Future<ApiResponse<List<ProductModel>>> getLowStockProducts({int? threshold}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (threshold != null) queryParams['threshold'] = threshold;
      
      final response = await apiService.get<List<ProductModel>>(
        '$baseEndpoint/low-stock',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get low stock products: $e');
      return ApiResponse<List<ProductModel>>.error('Failed to get low stock products: $e');
    }
  }
  
  // Product Analytics
  Future<ApiResponse<Map<String, dynamic>>> getProductStats() async {
    try {
      final response = await apiService.get<Map<String, dynamic>>(
        '$baseEndpoint/stats',
        parser: (data) => data as Map<String, dynamic>,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get product stats: $e');
      return ApiResponse<Map<String, dynamic>>.error('Failed to get product stats: $e');
    }
  }
  
  Future<ApiResponse<List<ProductModel>>> getTopSellingProducts({
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (limit != null) queryParams['limit'] = limit;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();
      
      final response = await apiService.get<List<ProductModel>>(
        '$baseEndpoint/top-selling',
        queryParameters: queryParams,
        parser: (data) {
          if (data is List) {
            return data.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get top selling products: $e');
      return ApiResponse<List<ProductModel>>.error('Failed to get top selling products: $e');
    }
  }
  
  Future<ApiResponse<bool>> updateProductStatus(String id, String status) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$id/status',
        data: {'status': status},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update product status: $e');
      return ApiResponse<bool>.error('Failed to update product status: $e');
    }
  }
  
  Future<ApiResponse<bool>> bulkUpdateProducts(List<String> ids, Map<String, dynamic> updates) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/bulk-update',
        data: {
          'ids': ids,
          'updates': updates,
        },
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to bulk update products: $e');
      return ApiResponse<bool>.error('Failed to bulk update products: $e');
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
      AppLogger.error('Failed to bulk delete products: $e');
      return ApiResponse<bool>.error('Failed to bulk delete products: $e');
    }
  }
}