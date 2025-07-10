import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class SecureStorage {
  final FlutterSecureStorage _storage;
  
  SecureStorage(this._storage);
  
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      AppLogger.debug('Token saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save token: $e');
      rethrow;
    }
  }
  
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      AppLogger.error('Failed to retrieve token: $e');
      return null;
    }
  }
  
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      AppLogger.debug('Token deleted successfully');
    } catch (e) {
      AppLogger.error('Failed to delete token: $e');
    }
  }
  
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      AppLogger.debug('Refresh token saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save refresh token: $e');
      rethrow;
    }
  }
  
  Future<String?> getRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      return refreshToken;
    } catch (e) {
      AppLogger.error('Failed to retrieve refresh token: $e');
      return null;
    }
  }
  
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
      AppLogger.debug('User ID saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save user ID: $e');
      rethrow;
    }
  }
  
  Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      return userId;
    } catch (e) {
      AppLogger.error('Failed to retrieve user ID: $e');
      return null;
    }
  }
  
  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _userEmailKey, value: email);
      AppLogger.debug('User email saved successfully');
    } catch (e) {
      AppLogger.error('Failed to save user email: $e');
      rethrow;
    }
  }
  
  Future<String?> getUserEmail() async {
    try {
      final email = await _storage.read(key: _userEmailKey);
      return email;
    } catch (e) {
      AppLogger.error('Failed to retrieve user email: $e');
      return null;
    }
  }
  
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      AppLogger.debug('All stored data cleared successfully');
    } catch (e) {
      AppLogger.error('Failed to clear all stored data: $e');
    }
  }
}
