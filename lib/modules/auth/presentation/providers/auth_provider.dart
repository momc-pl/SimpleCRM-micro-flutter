import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_crm_flutter/core/di/injection_container.dart';
import 'package:simple_crm_flutter/modules/auth/domain/entities/user.dart';
import 'package:simple_crm_flutter/modules/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:simple_crm_flutter/modules/auth/domain/usecases/login_usecase.dart';
import 'package:simple_crm_flutter/modules/auth/domain/usecases/logout_usecase.dart';
import 'package:simple_crm_flutter/core/utils/logger.dart';

// Auth state provider
final authStateProvider = AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

// Auth notifier
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    try {
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase.call();
      return result;
    } catch (e) {
      AppLogger.error('Failed to get current user', e);
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    
    try {
      final loginUseCase = sl<LoginUseCase>();
      
      final result = await loginUseCase.call(email, password);
      
      state = AsyncValue.data(result.user);
    } catch (e) {
      AppLogger.error('Login failed', e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> logout() async {
    try {
      final logoutUseCase = sl<LogoutUseCase>();
      await logoutUseCase.call();
      state = const AsyncValue.data(null);
    } catch (e) {
      AppLogger.error('Logout failed', e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshUser() async {
    try {
      final getCurrentUserUseCase = sl<GetCurrentUserUseCase>();
      final result = await getCurrentUserUseCase.call();
      
      state = AsyncValue.data(result);
    } catch (e) {
      AppLogger.error('Failed to refresh user', e);
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}