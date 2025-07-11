import 'package:simple_crm_flutter/core/services/health_check_service.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';
import 'package:simple_crm_flutter/core/config/api_config.dart';

/// Coordinates interactions between multiple microservices
/// Handles service discovery, load balancing, and circuit breaker patterns
class MicroservicesCoordinator {
  final HealthCheckService _healthCheckService;
  final Map<String, bool> _serviceStatus = {};
  final Map<String, DateTime> _lastHealthCheck = {};
  
  MicroservicesCoordinator(this._healthCheckService);
  
  Future<void> initialize() async {
    AppLogger.info('Initializing microservices coordinator...');
    
    // Wait for services to be ready
    final isReady = await _healthCheckService.waitForServicesReady();
    
    if (!isReady) {
      AppLogger.error('Failed to initialize: Some services are not ready');
      throw Exception('Microservices not ready');
    }
    
    // Start periodic health checks
    _startPeriodicHealthChecks();
    
    AppLogger.info('Microservices coordinator initialized successfully');
  }
  
  void _startPeriodicHealthChecks() {
    // Check health every 30 seconds
    Stream.periodic(const Duration(seconds: 30)).listen((_) async {
      await _updateServiceHealth();
    });
  }
  
  Future<void> _updateServiceHealth() async {
    try {
      final healthStatus = await _healthCheckService.checkAllServicesHealth();
      
      for (final entry in healthStatus.entries) {
        final serviceName = entry.key;
        final isHealthy = entry.value;
        
        if (_serviceStatus[serviceName] != isHealthy) {
          AppLogger.info('Service $serviceName status changed: ${isHealthy ? 'HEALTHY' : 'UNHEALTHY'}');
          _serviceStatus[serviceName] = isHealthy;
        }
        
        _lastHealthCheck[serviceName] = DateTime.now();
      }
    } catch (e) {
      AppLogger.error('Failed to update service health: $e');
    }
  }
  
  bool isServiceHealthy(String serviceName) {
    return _serviceStatus[serviceName] ?? false;
  }
  
  List<String> getHealthyServices() {
    return _serviceStatus.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  List<String> getUnhealthyServices() {
    return _serviceStatus.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  Map<String, bool> getAllServiceStatus() {
    return Map.from(_serviceStatus);
  }
  
  DateTime? getLastHealthCheck(String serviceName) {
    return _lastHealthCheck[serviceName];
  }
  
  /// Circuit breaker pattern - prevents calls to failing services
  bool canCallService(String serviceName) {
    if (!isServiceHealthy(serviceName)) {
      AppLogger.warning('Service $serviceName is unhealthy, preventing call');
      return false;
    }
    
    final lastCheck = getLastHealthCheck(serviceName);
    if (lastCheck == null) {
      return false;
    }
    
    // If last health check was more than 1 minute ago, consider it stale
    final isStale = DateTime.now().difference(lastCheck).inMinutes > 1;
    if (isStale) {
      AppLogger.warning('Service $serviceName health status is stale');
      return false;
    }
    
    return true;
  }
  
  /// Get service URL with fallback handling
  String getServiceUrl(String serviceName) {
    // In this implementation, all services go through API Gateway
    // In a more complex setup, this could return different URLs
    // for direct service communication or load balancing
    return ApiConfig.baseUrl;
  }
  
  /// Handle service unavailable scenarios
  Future<T?> callWithFallback<T>(
    String serviceName,
    Future<T> Function() serviceCall,
    T Function()? fallback,
  ) async {
    if (!canCallService(serviceName)) {
      if (fallback != null) {
        AppLogger.info('Using fallback for service $serviceName');
        return fallback();
      }
      return null;
    }
    
    try {
      return await serviceCall();
    } catch (e) {
      AppLogger.error('Service call failed for $serviceName: $e');
      
      // Mark service as unhealthy
      _serviceStatus[serviceName] = false;
      
      if (fallback != null) {
        AppLogger.info('Using fallback for failed service $serviceName');
        return fallback();
      }
      
      rethrow;
    }
  }
}