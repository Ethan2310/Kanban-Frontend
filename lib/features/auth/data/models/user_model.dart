import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleRaw = (json['role'] as String?) ?? UserRole.user.name;

    return UserModel(
      id: (json['id'] ?? json['userId']) as int,
      email: (json['email'] as String?) ?? '',
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == roleRaw.toLowerCase(),
        orElse: () => UserRole.user,
      ),
      isVerified: (json['isVerified'] as bool?) ?? true,
    );
  }

  factory UserModel.fromLoginJson(Map<String, dynamic> json) {
    return UserModel.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
    };
  }
}
