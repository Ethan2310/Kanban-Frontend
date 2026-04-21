import 'package:kanban_frontend/core/entities/base_entity.dart';

/// Represents the possible roles a user can have.
enum UserRole { admin, user }

class UserEntity extends BaseEntity {
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isVerified;

  const UserEntity({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isVerified,
  });

  /// Getter for the full name of the user.
  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        ...super.props,
        email,
        firstName,
        lastName,
        role,
        isVerified,
      ];
}
