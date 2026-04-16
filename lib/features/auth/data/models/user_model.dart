import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity{
  const UserModel({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role,
    required super.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      guid: json['guid'],
      createdById: json['createdById'],
      createdOn: DateTime.parse(json['createdOn']),
      updatedById: json['updatedById'],
      updatedOn: DateTime.parse(json['updatedOn']),
      isActive: json['isActive'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: UserRole.values.firstWhere((e) => e.toString() == 'UserRole.${json['role']}'),
      isVerified: json['isVerified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guid': guid,
      'createdById': createdById,
      'createdOn': createdOn.toIso8601String(),
      'updatedById': updatedById,
      'updatedOn': updatedOn.toIso8601String(),
      'isActive': isActive,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role.toString().split('.').last,
      'isVerified': isVerified,
    };
  }
}