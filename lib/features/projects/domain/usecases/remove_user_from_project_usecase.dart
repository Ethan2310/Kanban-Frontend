import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';

class RemoveUserFromProjectUsecase
    implements UseCase<bool, RemoveUserFromProjectParams> {
  final ProjectRepository repository;

  RemoveUserFromProjectUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(RemoveUserFromProjectParams params) async {
    return await repository.removeUserFromProject(
        params.projectId, params.userId);
  }
}

class RemoveUserFromProjectParams {
  final int projectId;
  final int userId;

  RemoveUserFromProjectParams({required this.projectId, required this.userId});
}
