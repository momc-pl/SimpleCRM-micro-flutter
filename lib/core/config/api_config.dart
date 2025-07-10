import 'package:flutter/foundation.dart';

enum Environment { development, staging, production }

class ApiConfig {
  static const Environment _currentEnvironment = Environment.development;
  
  static const Map<Environment, String> _baseUrls = {
    Environment.development: 'http://localhost:8080/api',
    Environment.staging: 'https://staging-api.simplecrm.com/api',
    Environment.production: 'https://api.simplecrm.com/api',
  };
  
  static const Map<Environment, Duration> _timeouts = {
    Environment.development: Duration(seconds: 30),
    Environment.staging: Duration(seconds: 25),
    Environment.production: Duration(seconds: 20),
  };
  
  static const Map<Environment, int> _retryAttempts = {
    Environment.development: 3,
    Environment.staging: 2,
    Environment.production: 2,
  };
  
  static const Map<Environment, bool> _enableLogging = {
    Environment.development: true,
    Environment.staging: true,
    Environment.production: false,
  };
  
  static String get baseUrl => _baseUrls[_currentEnvironment]!;
  static Duration get connectTimeout => _timeouts[_currentEnvironment]!;
  static Duration get receiveTimeout => _timeouts[_currentEnvironment]!;
  static int get maxRetryAttempts => _retryAttempts[_currentEnvironment]!;
  static bool get isLoggingEnabled => _enableLogging[_currentEnvironment]!;
  static Environment get currentEnvironment => _currentEnvironment;
  static bool get isDebugMode => kDebugMode;
  
  // API Version
  static const String apiVersion = 'v1';
  
  // Cache settings
  static const Duration cacheExpiration = Duration(minutes: 15);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  // Pagination defaults
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Rate limiting
  static const int maxRequestsPerMinute = 60;
  
  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableDataSync = true;
  static const bool enableRealTimeUpdates = true;
  
  // Security settings
  static const Duration tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration sessionTimeout = Duration(hours: 8);
}