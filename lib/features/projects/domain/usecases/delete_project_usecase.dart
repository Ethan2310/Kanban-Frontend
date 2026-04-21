import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class DeleteProjectUsecase implements UseCase<void, DeleteProjectParams> {
  final ProjectRepository repository;

  DeleteProjectUsecase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteProjectParams params) async {
    return await repository.deleteProject(params.projectId);
  }
}

class DeleteProjectParams {
  final int projectId;

  DeleteProjectParams({required this.projectId});
}
