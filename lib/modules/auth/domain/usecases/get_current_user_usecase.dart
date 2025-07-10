import 'package:simple_crm_flutter/modules/auth/domain/entities/user.dart';
import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository _repository;
  
  GetCurrentUserUseCase(this._repository);
  
  Future<User?> call() async {
    return await _repository.getCurrentUser();
  }
}
