import 'package:simple_crm_flutter/modules/customers/domain/entities/customer.dart';
import 'package:simple_crm_flutter/modules/customers/domain/repositories/customers_repository.dart';
import 'package:simple_crm_flutter/modules/customers/data/datasources/customers_remote_datasource.dart';
import 'package:simple_crm_flutter/modules/customers/data/models/customer_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDataSource _remoteDataSource;
  
  CustomersRepositoryImpl(this._remoteDataSource);
  
  @override
  Future<List<Customer>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? type,
    String? assignedUserId,
  }) async {
    try {
      final customerModels = await _remoteDataSource.getCustomers(
        page: page,
        limit: limit,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
        status: status,
        type: type,
        assignedUserId: assignedUserId,
      );
      
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Get customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Customer> getCustomerById(String id) async {
    try {
      final customerModel = await _remoteDataSource.getCustomerById(id);
      return customerModel.toEntity();
    } catch (e) {
      AppLogger.error('Get customer by ID failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Customer> createCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromEntity(customer);
      final createdModel = await _remoteDataSource.createCustomer(customerModel);
      return createdModel.toEntity();
    } catch (e) {
      AppLogger.error('Create customer failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Customer> updateCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromEntity(customer);
      final updatedModel = await _remoteDataSource.updateCustomer(customerModel);
      return updatedModel.toEntity();
    } catch (e) {
      AppLogger.error('Update customer failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> deleteCustomer(String id) async {
    try {
      await _remoteDataSource.deleteCustomer(id);
    } catch (e) {
      AppLogger.error('Delete customer failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Customer>> getCustomersByAssignedUser(String userId) async {
    try {
      final customerModels = await _remoteDataSource.getCustomersByAssignedUser(userId);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Get customers by assigned user failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final customerModels = await _remoteDataSource.searchCustomers(query);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Search customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Customer> assignCustomerToUser(String customerId, String userId) async {
    try {
      final customerModel = await _remoteDataSource.assignCustomerToUser(customerId, userId);
      return customerModel.toEntity();
    } catch (e) {
      AppLogger.error('Assign customer to user failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Customer>> getRecentCustomers(int limit) async {
    try {
      final customerModels = await _remoteDataSource.getRecentCustomers(limit);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Get recent customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Map<String, dynamic>> getCustomerStats() async {
    try {
      return await _remoteDataSource.getCustomerStats();
    } catch (e) {
      AppLogger.error('Get customer stats failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Customer>> getCustomersByTags(List<String> tags) async {
    try {
      final customerModels = await _remoteDataSource.getCustomersByTags(tags);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Get customers by tags failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<Customer> updateCustomerStatus(String customerId, String status) async {
    try {
      final customerModel = await _remoteDataSource.updateCustomerStatus(customerId, status);
      return customerModel.toEntity();
    } catch (e) {
      AppLogger.error('Update customer status failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> bulkUpdateCustomers(List<String> customerIds, Map<String, dynamic> updates) async {
    try {
      await _remoteDataSource.bulkUpdateCustomers(customerIds, updates);
    } catch (e) {
      AppLogger.error('Bulk update customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<void> bulkDeleteCustomers(List<String> customerIds) async {
    try {
      await _remoteDataSource.bulkDeleteCustomers(customerIds);
    } catch (e) {
      AppLogger.error('Bulk delete customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Customer>> importCustomers(List<Map<String, dynamic>> customersData) async {
    try {
      final customerModels = await _remoteDataSource.importCustomers(customersData);
      return customerModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      AppLogger.error('Import customers failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> exportCustomers({
    List<String>? customerIds,
    String? format,
  }) async {
    try {
      return await _remoteDataSource.exportCustomers(
        customerIds: customerIds,
        format: format,
      );
    } catch (e) {
      AppLogger.error('Export customers failed: $e');
      rethrow;
    }
  }
}