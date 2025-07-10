import 'package:simple_crm_flutter/modules/auth/domain/entities/auth_result.dart';
import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';

class RefreshTokenUseCase {
  final AuthRepository _repository;
  
  RefreshTokenUseCase(this._repository);
  
  Future<AuthResult> call(String refreshToken) async {
    if (refreshToken.isEmpty) {
      throw ArgumentError('Refresh token cannot be empty');
    }
    
    return await _repository.refreshToken(refreshToken);
  }
}
