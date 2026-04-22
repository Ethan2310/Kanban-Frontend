import 'package:equatable/equatable.dart';

/// Represents the possible roles a user can have.
enum UserRole { admin, user }

class UserEntity extends Equatable {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final UserRole role;
  final bool isVerified;

  const UserEntity({
    required this.id,
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
        id,
        email,
        firstName,
        lastName,
        role,
        isVerified,
      ];
}
