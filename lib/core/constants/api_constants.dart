class ApiConstants {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  
  // Customer endpoints
  static const String customers = '/customers';
  static const String customerById = '/customers/{id}';
  
  // Contact endpoints
  static const String contacts = '/contacts';
  static const String contactById = '/contacts/{id}';
  
  // Sales endpoints
  static const String sales = '/sales';
  static const String salesById = '/sales/{id}';
  
  // Dashboard endpoints
  static const String dashboardStats = '/dashboard/stats';
  static const String dashboardReports = '/dashboard/reports';
  
  // Product endpoints
  static const String products = '/products';
  static const String productById = '/products/{id}';
  
  // Order endpoints
  static const String orders = '/orders';
  static const String orderById = '/orders/{id}';
}
