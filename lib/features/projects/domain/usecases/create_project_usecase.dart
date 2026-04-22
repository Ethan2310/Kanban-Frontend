import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class CreateProjectUsecase
    implements UseCase<ProjectEntity, CreateProjectParams> {
  final ProjectRepository repository;

  CreateProjectUsecase(this.repository);
  @override
  Future<Either<Failure, ProjectEntity>> call(
      CreateProjectParams params) async {
    return await repository.createProject(
      params.name,
      params.description,
    );
  }
}

class CreateProjectParams {
  final String name;
  final String? description;

  CreateProjectParams({
    required this.name,
    this.description,
  });
}
