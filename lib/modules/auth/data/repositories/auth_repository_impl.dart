import 'package:simple_crm_flutter/modules/auth/domain/entities/auth_result.dart';
import 'package:simple_crm_flutter/modules/auth/domain/entities/user.dart';
import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';
import 'package:simple_crm_flutter/modules/auth/data/datasources/auth_remote_datasource.dart';
import 'package:simple_crm_flutter/core/storage/secure_storage.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;
  
  AuthRepositoryImpl(this._remoteDataSource, this._secureStorage);
  
  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final authResult = await _remoteDataSource.login(email, password);
      
      // Store tokens securely
      await _secureStorage.saveToken(authResult.accessToken);
      await _secureStorage.saveRefreshToken(authResult.refreshToken);
      await _secureStorage.saveUserId(authResult.user.id);
      await _secureStorage.saveUserEmail(authResult.user.email);
      
      AppLogger.info('Login successful for user: ${authResult.user.email}');
      
      return authResult;
    } catch (e) {
      AppLogger.error('Login failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final authResult = await _remoteDataSource.refreshToken(refreshToken);
      
      // Update stored tokens
      await _secureStorage.saveToken(authResult.accessToken);
      await _secureStorage.saveRefreshToken(authResult.refreshToken);
      
      AppLogger.info('Token refreshed successfully');
      
      return authResult;
    } catch (e) {
      AppLogger.error('Token refresh failed: $e');
      // Clear stored tokens if refresh fails
      await _secureStorage.clearAll();
      rethrow;
    }
  }
  
  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.clearAll();
      
      AppLogger.info('Logout successful');
    } catch (e) {
      // Still clear local storage even if server logout fails
      await _secureStorage.clearAll();
      AppLogger.error('Logout failed: $e');
      rethrow;
    }
  }
  
  @override
  Future<User?> getCurrentUser() async {
    try {
      final token = await _secureStorage.getToken();
      
      if (token == null) {
        return null;
      }
      
      final user = await _remoteDataSource.getCurrentUser();
      return user;
    } catch (e) {
      AppLogger.error('Get current user failed: $e');
      // If token is invalid, clear storage
      await _secureStorage.clearAll();
      return null;
    }
  }
  
  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _secureStorage.getToken();
      return token != null;
    } catch (e) {
      AppLogger.error('Check authentication failed: $e');
      return false;
    }
  }
}
