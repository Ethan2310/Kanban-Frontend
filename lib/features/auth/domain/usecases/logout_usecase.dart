import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';

class LogOutUseCase implements UseCase<void, NoParams> {
  final AuthRepository repository;

  LogOutUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
