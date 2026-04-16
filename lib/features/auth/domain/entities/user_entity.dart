import 'package:equatable/equatable.dart';

/// Base class for all entities in the system to ensure
/// consistency across the data layer.
abstract class BaseEntity extends Equatable {
  final int id;
  final String guid;
  final int? createdById;
  final DateTime createdOn;
  final int? updatedById;
  final DateTime updatedOn;
  final bool isActive;

  const BaseEntity({
    required this.id,
    required this.guid,
    this.createdById,
    required this.createdOn,
    this.updatedById,
    required this.updatedOn,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        guid,
        createdById,
        createdOn,
        updatedById,
        updatedOn,
        isActive,
      ];
}

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
