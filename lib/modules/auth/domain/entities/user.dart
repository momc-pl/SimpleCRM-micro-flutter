import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> roles;
  
  const User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
    required this.roles,
  });
  
  @override
  List<Object?> get props => [
    id,
    email,
    name,
    profilePicture,
    createdAt,
    updatedAt,
    roles,
  ];
  
  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePicture,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? roles,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      roles: roles ?? this.roles,
    );
  }
}
