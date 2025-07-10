import 'package:simple_crm_flutter/modules/customers/domain/entities/customer.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getCustomers({
    int? page,
    int? limit,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? status,
    String? type,
    String? assignedUserId,
  });
  
  Future<Customer> getCustomerById(String id);
  
  Future<Customer> createCustomer(Customer customer);
  
  Future<Customer> updateCustomer(Customer customer);
  
  Future<void> deleteCustomer(String id);
  
  Future<List<Customer>> getCustomersByAssignedUser(String userId);
  
  Future<List<Customer>> searchCustomers(String query);
  
  Future<Customer> assignCustomerToUser(String customerId, String userId);
  
  Future<List<Customer>> getRecentCustomers(int limit);
  
  Future<Map<String, dynamic>> getCustomerStats();
  
  Future<List<Customer>> getCustomersByTags(List<String> tags);
  
  Future<Customer> updateCustomerStatus(String customerId, String status);
  
  Future<void> bulkUpdateCustomers(List<String> customerIds, Map<String, dynamic> updates);
  
  Future<void> bulkDeleteCustomers(List<String> customerIds);
  
  Future<List<Customer>> importCustomers(List<Map<String, dynamic>> customersData);
  
  Future<List<Map<String, dynamic>>> exportCustomers({
    List<String>? customerIds,
    String? format,
  });
}