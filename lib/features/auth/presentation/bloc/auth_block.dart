import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/get_current_user.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/auth_event.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/auth_state.dart';

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
  }

  Future _onAuthCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await checkAuthUseCase(NoParams());

    await result.fold((l) {
      emit(AuthUnauthenticated());
    }, (r) async {
      if (r) {
        final userResult = await getCurrentUserUseCase(NoParams());
        await userResult.fold((l) {
          emit(AuthUnauthenticated());
        }, (r) {
          if (r != null) {
            emit(AuthAuthenticated(userEntity: r));
          } else {
            emit(AuthUnauthenticated());
          }
        });
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password));

    result.fold((l) {
      String message = 'Login Error';
      if (l is InvalidCredentialsFailure) {
        message = 'Invalid credentials: ${l.message}';
      } else if (l is ServerFailure) {
        message = 'Server error: ${l.message}';
      }
      emit(AuthError(message: message));
    }, (r) {
      emit(AuthAuthenticated(userEntity: r));
    });
  }

  Future _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await logOutUseCase(NoParams());

    result.fold((l) {
      String message = 'Logout Error';
      if (l is ServerFailure) {
        message = 'Server error: ${l.message}';
      }
      emit(AuthError(message: message));
    }, (r) {
      emit(AuthUnauthenticated());
    });
  }

  Future _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    final result = await registerUseCase(RegisterParams(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      role: event.role,
    ));

    result.fold((l) {
      String message = 'Registration Error';
      if (l is ConflictFailure) {
        message = 'Conflict error: ${l.message}';
      } else if (l is ServerFailure) {
        message = 'Server error: ${l.message}';
      }
      emit(AuthError(message: message));
    }, (r) {
      emit(AuthInitial());
    });
  }
}
