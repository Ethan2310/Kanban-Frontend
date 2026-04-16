import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';

class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  @override
  Future<Either<Failure, UserEntity?>> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}