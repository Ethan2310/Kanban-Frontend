import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';
import 'package:kanban_frontend/core/error/failures.dart';

abstract class ProjectRepository {
  Future<Either<Failure, ProjectEntity>> createProject(
      String name, String? description);
  Future<Either<Failure, void>> deleteProject(int projectId);
  Future<Either<Failure, ProjectEntity>> updateProject(
      int projectId, String newName, String? newDescription);
  Future<Either<Failure, ProjectListEntity>> getProjects(
      int? boardId, int? userId, String? name);
  Future<Either<Failure, ProjectUserAccessEntity>> addUserToProject(
      int projectId, int userId);
  Future<Either<Failure, List<ProjectUserAccessEntity>>> getProjectUsers(
      int projectId);
  Future<Either<Failure, bool>> removeUserFromProject(
      int projectId, int userId);
}
