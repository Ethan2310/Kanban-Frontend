import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

class LoginUseCase implements UseCase<UserEntity,LoginParams>{
  final AuthRepository repository;
  LoginUseCase({required this.repository});

  @override
  Future<Either<Failure, UserEntity>> call(LoginParams params) async {
    return await repository.login(email: params.email, password: params.password);

  }
}

class LoginParams{
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}