import 'package:simple_crm_flutter/core/network/dio_client.dart';
import 'package:simple_crm_flutter/core/constants/api_constants.dart';
import 'package:simple_crm_flutter/modules/auth/data/models/auth_result_model.dart';
import 'package:simple_crm_flutter/modules/auth/data/models/login_request_model.dart';
import 'package:simple_crm_flutter/modules/auth/data/models/user_model.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient;
  
  AuthRemoteDataSource(this._dioClient);
  
  Future<AuthResultModel> login(String email, String password) async {
    try {
      final loginRequest = LoginRequestModel(
        email: email,
        password: password,
      );
      
      final response = await _dioClient.post(
        ApiConstants.login,
        data: loginRequest.toJson(),
      );
      
      AppLogger.debug('Login response: ${response.data}');
      
      return AuthResultModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Login failed: $e');
      rethrow;
    }
  }
  
  Future<AuthResultModel> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiConstants.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      
      AppLogger.debug('Refresh token response: ${response.data}');
      
      return AuthResultModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Refresh token failed: $e');
      rethrow;
    }
  }
  
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiConstants.logout);
      AppLogger.debug('Logout successful');
    } catch (e) {
      AppLogger.error('Logout failed: $e');
      rethrow;
    }
  }
  
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiConstants.currentUser);
      
      AppLogger.debug('Get current user response: ${response.data}');
      
      return UserModel.fromJson(response.data);
    } catch (e) {
      AppLogger.error('Get current user failed: $e');
      rethrow;
    }
  }
}
