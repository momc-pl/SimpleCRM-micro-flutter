import 'package:simple_crm_flutter/core/network/dio_client.dart';
import 'package:simple_crm_flutter/core/constants/api_constants.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class HealthCheckService {
  final DioClient _dioClient;
  
  HealthCheckService(this._dioClient);
  
  Future<bool> checkApiGatewayHealth() async {
    try {
      final response = await _dioClient.get(ApiConstants.healthCheck);
      final isHealthy = response.statusCode == 200;
      
      AppLogger.info('API Gateway health check: ${isHealthy ? 'HEALTHY' : 'UNHEALTHY'}');
      return isHealthy;
    } catch (e) {
      AppLogger.error('API Gateway health check failed: $e');
      return false;
    }
  }
  
  Future<Map<String, bool>> checkAllServicesHealth() async {
    final healthStatus = <String, bool>{};
    
    // Check API Gateway
    healthStatus['api-gateway'] = await checkApiGatewayHealth();
    
    // Check individual services through gateway
    final services = [
      'auth-service',
      'customer-service', 
      'product-service',
      'order-service',
      'sales-service'
    ];
    
    for (final service in services) {
      try {
        final response = await _dioClient.get('/actuator/health/$service');
        healthStatus[service] = response.statusCode == 200;
        AppLogger.info('$service health: ${healthStatus[service] ? 'HEALTHY' : 'UNHEALTHY'}');
      } catch (e) {
        healthStatus[service] = false;
        AppLogger.warning('$service health check failed: $e');
      }
    }
    
    return healthStatus;
  }
  
  Future<bool> waitForServicesReady({Duration timeout = const Duration(minutes: 2)}) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      final health = await checkAllServicesHealth();
      final allHealthy = health.values.every((isHealthy) => isHealthy);
      
      if (allHealthy) {
        AppLogger.info('All microservices are ready');
        return true;
      }
      
      AppLogger.info('Waiting for services to be ready... ${stopwatch.elapsed.inSeconds}s');
      await Future.delayed(const Duration(seconds: 5));
    }
    
    AppLogger.error('Services not ready after ${timeout.inMinutes} minutes');
    return false;
  }
}