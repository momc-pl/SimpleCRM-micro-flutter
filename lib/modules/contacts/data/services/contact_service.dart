import 'package:simple_crm_flutter/core/services/base_service.dart';
import 'package:simple_crm_flutter/core/network/api_service.dart';
import 'package:simple_crm_flutter/core/network/models/api_response.dart';
import 'package:simple_crm_flutter/modules/contacts/data/models/contact_model.dart';
import 'package:simple_crm_flutter/modules/contacts/data/models/contact_create_request.dart';
import 'package:simple_crm_flutter/modules/contacts/data/models/contact_update_request.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class ContactService extends BaseService {
  ContactService(ApiService apiService) : super(apiService);
  
  @override
  String get baseEndpoint => '/contacts';
  
  Future<ApiResponse<List<ContactModel>>> getContacts({
    int? page,
    int? limit,
    String? search,
    String? customerId,
    String? type,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (page != null) queryParams['page'] = page;
      if (limit != null) queryParams['limit'] = limit;
      if (search != null) queryParams['search'] = search;
      if (customerId != null) queryParams['customer_id'] = customerId;
      if (type != null) queryParams['type'] = type;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;
      
      return await getList<ContactModel>(
        queryParameters: queryParams,
        fromJson: (json) => ContactModel.fromJson(json),
      );
    } catch (e) {
      AppLogger.error('Failed to get contacts: $e');
      return ApiResponse<List<ContactModel>>.error('Failed to get contacts: $e');
    }
  }
  
  Future<ApiResponse<ContactModel>> getContactById(String id) async {
    return await getById<ContactModel>(
      id: id,
      fromJson: (json) => ContactModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<ContactModel>> createContact(ContactCreateRequest request) async {
    return await create<ContactModel>(
      data: request.toJson(),
      fromJson: (json) => ContactModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<ContactModel>> updateContact(
    String id,
    ContactUpdateRequest request,
  ) async {
    return await update<ContactModel>(
      id: id,
      data: request.toJson(),
      fromJson: (json) => ContactModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<bool>> deleteContact(String id) async {
    return await delete(id: id);
  }
  
  Future<ApiResponse<List<ContactModel>>> searchContacts(String query) async {
    return await search<ContactModel>(
      query: query,
      fromJson: (json) => ContactModel.fromJson(json),
    );
  }
  
  Future<ApiResponse<List<ContactModel>>> getContactsByCustomer(String customerId) async {
    try {
      final response = await apiService.get<List<ContactModel>>(
        '/customers/$customerId/contacts',
        parser: (data) {
          if (data is List) {
            return data.map((item) => ContactModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          throw Exception('Expected List but got ${data.runtimeType}');
        },
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get contacts for customer $customerId: $e');
      return ApiResponse<List<ContactModel>>.error('Failed to get contacts for customer: $e');
    }
  }
  
  Future<ApiResponse<ContactModel>> getPrimaryContact(String customerId) async {
    try {
      final response = await apiService.get<ContactModel>(
        '/customers/$customerId/contacts/primary',
        parser: (data) => ContactModel.fromJson(data as Map<String, dynamic>),
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to get primary contact for customer $customerId: $e');
      return ApiResponse<ContactModel>.error('Failed to get primary contact: $e');
    }
  }
  
  Future<ApiResponse<bool>> setPrimaryContact(String customerId, String contactId) async {
    try {
      final response = await apiService.put<bool>(
        '/customers/$customerId/contacts/$contactId/primary',
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to set primary contact: $e');
      return ApiResponse<bool>.error('Failed to set primary contact: $e');
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
      AppLogger.error('Failed to bulk delete contacts: $e');
      return ApiResponse<bool>.error('Failed to bulk delete contacts: $e');
    }
  }
  
  Future<ApiResponse<bool>> updateContactType(String id, String type) async {
    try {
      final response = await apiService.put<bool>(
        '$baseEndpoint/$id/type',
        data: {'type': type},
        parser: (data) => true,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Failed to update contact type: $e');
      return ApiResponse<bool>.error('Failed to update contact type: $e');
    }
  }
}