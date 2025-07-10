import 'package:simple_crm_flutter/modules/auth/domain/entities/auth_result.dart';
import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  
  LoginUseCase(this._repository);
  
  Future<AuthResult> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password cannot be empty');
    }
    
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format');
    }
    
    return await _repository.login(email, password);
  }
  
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
