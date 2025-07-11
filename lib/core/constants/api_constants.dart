class ApiConstants {
  static const String baseUrl = 'http://localhost:8090/api';
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Auth Service endpoints (through API Gateway)
  static const String login = '/v1/auth/login';
  static const String logout = '/v1/auth/logout';
  static const String refreshToken = '/v1/auth/refresh';
  static const String register = '/v1/auth/register';
  static const String currentUser = '/v1/auth/me';
  
  // Customer Service endpoints (through API Gateway)
  static const String customers = '/v1/customers';
  static const String customerById = '/v1/customers/{id}';
  static const String customerStats = '/v1/customers/stats';
  static const String recentCustomers = '/v1/customers/recent';
  static const String customerBulkDelete = '/v1/customers/bulk';
  static const String customerStatus = '/v1/customers/{id}/status';
  
  // Contact Service endpoints (through API Gateway)
  static const String contacts = '/v1/contacts';
  static const String contactById = '/v1/contacts/{id}';
  
  // Product Service endpoints (through API Gateway)
  static const String products = '/v1/products';
  static const String productById = '/v1/products/{id}';
  static const String productStats = '/v1/products/stats';
  static const String productCategories = '/v1/products/categories';
  
  // Order Service endpoints (through API Gateway)
  static const String orders = '/v1/orders';
  static const String orderById = '/v1/orders/{id}';
  static const String orderStats = '/v1/orders/stats';
  
  // Sales Pipeline Service endpoints (through API Gateway)
  static const String sales = '/v1/sales';
  static const String salesById = '/v1/sales/{id}';
  static const String salesPipeline = '/v1/sales/pipeline';
  static const String salesStats = '/v1/sales/stats';
  
  // Dashboard endpoints (aggregated data through API Gateway)
  static const String dashboardStats = '/v1/dashboard/stats';
  static const String dashboardReports = '/v1/dashboard/reports';
  static const String dashboardMetrics = '/v1/dashboard/metrics';
  
  // Gateway health check
  static const String healthCheck = '/actuator/health';
}
