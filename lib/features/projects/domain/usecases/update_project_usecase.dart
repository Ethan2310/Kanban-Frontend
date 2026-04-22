import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:kanban_frontend/core/error/failures.dart';

class UpdateProjectUsecase
    implements UseCase<ProjectEntity, UpdateProjectParams> {
  final ProjectRepository repository;

  UpdateProjectUsecase(this.repository);

  @override
  Future<Either<Failure, ProjectEntity>> call(UpdateProjectParams params) {
    return repository.updateProject(
        params.projectId, params.newName, params.newDescription);
  }
}

class UpdateProjectParams {
  final int projectId;
  final String newName;
  final String? newDescription;

  UpdateProjectParams({
    required this.projectId,
    required this.newName,
    this.newDescription,
  });
}
