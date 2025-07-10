import 'package:simple_crm_flutter/modules/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository _repository;
  
  LogoutUseCase(this._repository);
  
  Future<void> call() async {
    await _repository.logout();
  }
}
