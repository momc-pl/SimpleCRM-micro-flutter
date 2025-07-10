import 'package:simple_crm_flutter/modules/auth/domain/entities/auth_result.dart';
import 'package:simple_crm_flutter/modules/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> refreshToken(String refreshToken);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<bool> isAuthenticated();
}
