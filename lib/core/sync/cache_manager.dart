import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_crm_flutter/core/config/api_config.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class CacheManager {
  static CacheManager? _instance;
  SharedPreferences? _prefs;
  
  static CacheManager get instance {
    _instance ??= CacheManager._internal();
    return _instance!;
  }
  
  CacheManager._internal();
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    AppLogger.debug('Cache manager initialized');
  }
  
  // Cache key generation
  String _generateCacheKey(String key, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return 'cache_$key';
    }
    
    final paramsString = params.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    return 'cache_${key}_$paramsString';
  }
  
  String _generateMetaKey(String cacheKey) {
    return '${cacheKey}_meta';
  }
  
  // Cache operations
  Future<bool> set<T>(String key, T data, {Map<String, dynamic>? params, Duration? ttl}) async {
    try {
      final cacheKey = _generateCacheKey(key, params: params);
      final metaKey = _generateMetaKey(cacheKey);
      
      final jsonData = jsonEncode(data);
      final expiry = ttl != null 
          ? DateTime.now().add(ttl).millisecondsSinceEpoch
          : DateTime.now().add(ApiConfig.cacheExpiration).millisecondsSinceEpoch;
      
      final meta = {
        'expiry': expiry,
        'created': DateTime.now().millisecondsSinceEpoch,
        'size': jsonData.length,
      };
      
      await _prefs?.setString(cacheKey, jsonData);
      await _prefs?.setString(metaKey, jsonEncode(meta));
      
      AppLogger.debug('Cached data for key: $cacheKey');
      return true;
    } catch (e) {
      AppLogger.error('Failed to cache data: $e');
      return false;
    }
  }
  
  Future<T?> get<T>(String key, {Map<String, dynamic>? params, T Function(Map<String, dynamic>)? fromJson}) async {
    try {
      final cacheKey = _generateCacheKey(key, params: params);
      final metaKey = _generateMetaKey(cacheKey);
      
      final cachedData = _prefs?.getString(cacheKey);
      final metaData = _prefs?.getString(metaKey);
      
      if (cachedData == null || metaData == null) {
        return null;
      }
      
      final meta = jsonDecode(metaData) as Map<String, dynamic>;
      final expiry = meta['expiry'] as int;
      
      if (DateTime.now().millisecondsSinceEpoch > expiry) {
        await remove(key, params: params);
        AppLogger.debug('Cache expired for key: $cacheKey');
        return null;
      }
      
      final decodedData = jsonDecode(cachedData);
      
      if (fromJson != null && decodedData is Map<String, dynamic>) {
        return fromJson(decodedData);
      }
      
      return decodedData as T?;
    } catch (e) {
      AppLogger.error('Failed to retrieve cached data: $e');
      return null;
    }
  }
  
  Future<bool> remove(String key, {Map<String, dynamic>? params}) async {
    try {
      final cacheKey = _generateCacheKey(key, params: params);
      final metaKey = _generateMetaKey(cacheKey);
      
      await _prefs?.remove(cacheKey);
      await _prefs?.remove(metaKey);
      
      AppLogger.debug('Removed cache for key: $cacheKey');
      return true;
    } catch (e) {
      AppLogger.error('Failed to remove cached data: $e');
      return false;
    }
  }
  
  Future<bool> exists(String key, {Map<String, dynamic>? params}) async {
    final cacheKey = _generateCacheKey(key, params: params);
    final metaKey = _generateMetaKey(cacheKey);
    
    final cachedData = _prefs?.getString(cacheKey);
    final metaData = _prefs?.getString(metaKey);
    
    if (cachedData == null || metaData == null) {
      return false;
    }
    
    final meta = jsonDecode(metaData) as Map<String, dynamic>;
    final expiry = meta['expiry'] as int;
    
    return DateTime.now().millisecondsSinceEpoch <= expiry;
  }
  
  Future<void> clear() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final cacheKeys = keys.where((key) => key.startsWith('cache_'));
      
      for (final key in cacheKeys) {
        await _prefs?.remove(key);
      }
      
      AppLogger.debug('Cleared all cache data');
    } catch (e) {
      AppLogger.error('Failed to clear cache: $e');
    }
  }
  
  Future<void> clearExpired() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final metaKeys = keys.where((key) => key.startsWith('cache_') && key.endsWith('_meta'));
      
      for (final metaKey in metaKeys) {
        final metaData = _prefs?.getString(metaKey);
        if (metaData != null) {
          final meta = jsonDecode(metaData) as Map<String, dynamic>;
          final expiry = meta['expiry'] as int;
          
          if (DateTime.now().millisecondsSinceEpoch > expiry) {
            final cacheKey = metaKey.replaceAll('_meta', '');
            await _prefs?.remove(cacheKey);
            await _prefs?.remove(metaKey);
          }
        }
      }
      
      AppLogger.debug('Cleared expired cache data');
    } catch (e) {
      AppLogger.error('Failed to clear expired cache: $e');
    }
  }
  
  Future<Map<String, dynamic>> getStats() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final cacheKeys = keys.where((key) => key.startsWith('cache_') && !key.endsWith('_meta'));
      final metaKeys = keys.where((key) => key.startsWith('cache_') && key.endsWith('_meta'));
      
      int totalSize = 0;
      int expiredCount = 0;
      
      for (final metaKey in metaKeys) {
        final metaData = _prefs?.getString(metaKey);
        if (metaData != null) {
          final meta = jsonDecode(metaData) as Map<String, dynamic>;
          final expiry = meta['expiry'] as int;
          final size = meta['size'] as int;
          
          totalSize += size;
          
          if (DateTime.now().millisecondsSinceEpoch > expiry) {
            expiredCount++;
          }
        }
      }
      
      return {
        'total_entries': cacheKeys.length,
        'expired_entries': expiredCount,
        'total_size_bytes': totalSize,
        'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      };
    } catch (e) {
      AppLogger.error('Failed to get cache stats: $e');
      return {};
    }
  }
  
  // Prefetch common data
  Future<void> prefetchData(Map<String, Future<dynamic>> prefetchMap) async {
    try {
      AppLogger.debug('Starting data prefetch...');
      
      final futures = prefetchMap.entries.map((entry) async {
        try {
          final data = await entry.value;
          await set(entry.key, data);
          AppLogger.debug('Prefetched: ${entry.key}');
        } catch (e) {
          AppLogger.error('Failed to prefetch ${entry.key}: $e');
        }
      });
      
      await Future.wait(futures);
      AppLogger.debug('Data prefetch completed');
    } catch (e) {
      AppLogger.error('Failed to prefetch data: $e');
    }
  }
  
  // Cache invalidation patterns
  Future<void> invalidateByPattern(String pattern) async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      final matchingKeys = keys.where((key) => key.contains(pattern));
      
      for (final key in matchingKeys) {
        await _prefs?.remove(key);
      }
      
      AppLogger.debug('Invalidated cache entries matching pattern: $pattern');
    } catch (e) {
      AppLogger.error('Failed to invalidate cache by pattern: $e');
    }
  }
  
  Future<void> invalidateByTags(List<String> tags) async {
    try {
      for (final tag in tags) {
        await invalidateByPattern('_$tag');
      }
      
      AppLogger.debug('Invalidated cache entries with tags: $tags');
    } catch (e) {
      AppLogger.error('Failed to invalidate cache by tags: $e');
    }
  }
}