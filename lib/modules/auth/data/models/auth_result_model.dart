import 'package:json_annotation/json_annotation.dart';
import 'package:simple_crm_flutter/modules/auth/domain/entities/auth_result.dart';
import 'package:simple_crm_flutter/modules/auth/data/models/user_model.dart';

part 'auth_result_model.g.dart';

@JsonSerializable()
class AuthResultModel extends AuthResult {
  const AuthResultModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    required super.expiresAt,
  });
  
  factory AuthResultModel.fromJson(Map<String, dynamic> json) => _$AuthResultModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuthResultModelToJson(this);
  
  factory AuthResultModel.fromEntity(AuthResult authResult) {
    return AuthResultModel(
      user: authResult.user,
      accessToken: authResult.accessToken,
      refreshToken: authResult.refreshToken,
      expiresAt: authResult.expiresAt,
    );
  }
}
