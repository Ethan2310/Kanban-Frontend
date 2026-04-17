part of 'auth_bloc.dart';

enum AuthErrorType { generic, invalidCredentials, conflict, server }

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity userEntity;

  AuthAuthenticated({required this.userEntity});

  @override
  List<Object?> get props => [userEntity];
}

class AuthError extends AuthState {
  final String message;
  final AuthErrorType type;

  AuthError({required this.message, this.type = AuthErrorType.generic});

  @override
  List<Object?> get props => [message, type];
}

class AuthUnauthenticated extends AuthState {}

class AuthRegistering extends AuthState {}

class AuthRegistrationSuccess extends AuthState {
  final String email;

  AuthRegistrationSuccess({required this.email});

  @override
  List<Object?> get props => [email];
}
