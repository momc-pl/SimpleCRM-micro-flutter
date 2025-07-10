import 'package:equatable/equatable.dart';
import 'package:simple_crm_flutter/modules/auth/domain/entities/user.dart';

class AuthResult extends Equatable {
  final User user;
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  
  const AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
  
  @override
  List<Object?> get props => [
    user,
    accessToken,
    refreshToken,
    expiresAt,
  ];
  
  AuthResult copyWith({
    User? user,
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
  }) {
    return AuthResult(
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
