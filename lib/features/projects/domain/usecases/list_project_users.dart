import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';

class ListProjectUsers
    implements UseCase<List<ProjectUserAccessEntity>, ListProjectUsersParams> {
  final ProjectRepository repository;

  ListProjectUsers(this.repository);

  @override
  Future<Either<Failure, List<ProjectUserAccessEntity>>> call(
      ListProjectUsersParams params) async {
    return await repository.getProjectUsers(params.projectId);
  }
}

class ListProjectUsersParams {
  final int projectId;

  ListProjectUsersParams({required this.projectId});
}
