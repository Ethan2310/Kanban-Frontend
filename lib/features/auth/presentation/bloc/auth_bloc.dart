import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/get_current_user.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogOutUseCase logOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AuthCheckUseCase checkAuthUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logOutUseCase,
    required this.getCurrentUserUseCase,
    required this.checkAuthUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthNavigateToRegister>(_onAuthNavigateToRegister);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await checkAuthUseCase(NoParams());

    await result.fold(
      (failure) {
        emit(AuthUnauthenticated());
      },
      (isAuthenticated) async {
        if (!isAuthenticated) {
          emit(AuthUnauthenticated());
          return;
        }

        final userResult = await getCurrentUserUseCase(NoParams());
        userResult.fold(
          (failure) {
            emit(AuthUnauthenticated());
          },
          (user) {
            if (user != null) {
              emit(AuthAuthenticated(userEntity: user));
              return;
            }

            emit(AuthUnauthenticated());
          },
        );
      },
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );

    result.fold(
      (failure) {
        var message = 'Login Error';
        var errorType = AuthErrorType.generic;
        if (failure is InvalidCredentialsFailure) {
          message = 'Invalid credentials: ${failure.message}';
          errorType = AuthErrorType.invalidCredentials;
        } else if (failure is ServerFailure) {
          message =
              'Server error: ${failure.message ?? 'Unable to reach auth service.'}';
          errorType = AuthErrorType.server;
        }
        emit(AuthError(message: message, type: errorType));
      },
      (user) {
        emit(AuthAuthenticated(userEntity: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logOutUseCase(NoParams());

    result.fold(
      (failure) {
        var message = 'Logout Error';
        var errorType = AuthErrorType.generic;
        if (failure is ServerFailure) {
          message =
              'Server error: ${failure.message ?? 'Unable to reach auth service.'}';
          errorType = AuthErrorType.server;
        }
        emit(AuthError(message: message, type: errorType));
      },
      (_) {
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUseCase(
      RegisterParams(
        email: event.email,
        password: event.password,
        firstName: event.firstName,
        lastName: event.lastName,
        role: event.role,
      ),
    );

    result.fold(
      (failure) {
        var message = 'Registration Error';
        var errorType = AuthErrorType.generic;
        if (failure is ConflictFailure) {
          message = 'Conflict error: ${failure.message}';
          errorType = AuthErrorType.conflict;
        } else if (failure is ServerFailure) {
          message =
              'Server error: ${failure.message ?? 'Unable to reach auth service.'}';
          errorType = AuthErrorType.server;
        }
        emit(AuthError(message: message, type: errorType));
      },
      (_) {
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onAuthNavigateToRegister(
    AuthNavigateToRegister event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthRegistering());
  }
}
