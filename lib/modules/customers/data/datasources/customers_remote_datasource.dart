import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:simple_crm_flutter/modules/customers/data/models/customer_model.dart';
import 'package:simple_crm_flutter/core/constants/api_constants.dart';

part 'customers_remote_datasource.g.dart';

@RestApi(baseUrl: ApiConstants.baseUrl)
abstract class CustomersRemoteDataSource {
  factory CustomersRemoteDataSource(Dio dio) = _CustomersRemoteDataSource;
  
  @GET('/customers')
  Future<List<CustomerModel>> getCustomers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
    @Query('sortBy') String? sortBy,
    @Query('sortOrder') String? sortOrder,
    @Query('status') String? status,
    @Query('type') String? type,
    @Query('assignedUserId') String? assignedUserId,
  });
  
  @GET('/customers/{id}')
  Future<CustomerModel> getCustomerById(@Path('id') String id);
  
  @POST('/customers')
  Future<CustomerModel> createCustomer(@Body() CustomerModel customer);
  
  @PUT('/customers/{id}')
  Future<CustomerModel> updateCustomer(@Path('id') String id, @Body() CustomerModel customer);
  
  @DELETE('/customers/{id}')
  Future<void> deleteCustomer(@Path('id') String id);
  
  @GET('/customers/assigned/{userId}')
  Future<List<CustomerModel>> getCustomersByAssignedUser(@Path('userId') String userId);
  
  @GET('/customers/search')
  Future<List<CustomerModel>> searchCustomers(@Query('q') String query);
  
  @PUT('/customers/{id}/assign/{userId}')
  Future<CustomerModel> assignCustomerToUser(
    @Path('id') String customerId,
    @Path('userId') String userId,
  );
  
  @GET('/customers/recent')
  Future<List<CustomerModel>> getRecentCustomers(@Query('limit') int limit);
  
  @GET('/customers/stats')
  Future<Map<String, dynamic>> getCustomerStats();
  
  @GET('/customers/tags')
  Future<List<CustomerModel>> getCustomersByTags(@Query('tags') List<String> tags);
  
  @PUT('/customers/{id}/status')
  Future<CustomerModel> updateCustomerStatus(
    @Path('id') String customerId,
    @Body() Map<String, String> statusUpdate,
  );
  
  @PUT('/customers/bulk-update')
  Future<void> bulkUpdateCustomers(
    @Body() Map<String, dynamic> bulkUpdate,
  );
  
  @DELETE('/customers/bulk-delete')
  Future<void> bulkDeleteCustomers(@Body() List<String> customerIds);
  
  @POST('/customers/import')
  Future<List<CustomerModel>> importCustomers(
    @Body() List<Map<String, dynamic>> customersData,
  );
  
  @GET('/customers/export')
  Future<List<Map<String, dynamic>>> exportCustomers({
    @Query('customerIds') List<String>? customerIds,
    @Query('format') String? format,
  });
}