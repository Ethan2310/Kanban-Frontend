import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class AddUserToProjectUsecase
    implements UseCase<ProjectUserAccessEntity, AddUserToProjectParams> {
  final ProjectRepository repository;

  AddUserToProjectUsecase(this.repository);

  @override
  Future<Either<Failure, ProjectUserAccessEntity>> call(
      AddUserToProjectParams params) async {
    return await repository.addUserToProject(params.projectId, params.userId);
  }
}

class AddUserToProjectParams {
  final int projectId;
  final int userId;

  AddUserToProjectParams({required this.projectId, required this.userId});
}
