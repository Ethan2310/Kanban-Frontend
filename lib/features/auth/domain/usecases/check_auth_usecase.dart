import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthCheckUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  AuthCheckUseCase({ required this.repository });

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
} 