import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/projects/data/datasources/project_local_datasource.dart';
import 'package:kanban_frontend/features/projects/data/datasources/project_remote_datasource.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource remoteDataSource;
  final ProjectLocalDataSource localDataSource;

  ProjectRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, ProjectListEntity>> getProjects(
      int? boardId, int? userId, String? name) async {
    try {
      final remoteProjects =
          await remoteDataSource.getProjects(boardId, userId, name);
      return Right(remoteProjects);
    } catch (e) {
      final localProjects = await localDataSource.getCachedProjects();
      if (localProjects.projects.isNotEmpty) {
        return Right(localProjects);
      } else {
        return Left(ServerFailure(message: "Failed to fetch projects: $e"));
      }
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> createProject(
      String name, String? description) async {
    try {
      final newProject =
          await remoteDataSource.createProject(name, description);
      return Right(newProject);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to create project: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(int projectId) async {
    try {
      await remoteDataSource.deleteProject(projectId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to delete project: $e"));
    }
  }

  @override
  Future<Either<Failure, ProjectEntity>> updateProject(
      int projectId, String newName, String? newDescription) async {
    try {
      final updatedProject = await remoteDataSource.updateProject(
          projectId, newName, newDescription);
      return Right(updatedProject);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to update project: $e"));
    }
  }

  @override
  Future<Either<Failure, ProjectUserAccessEntity>> addUserToProject(
      int projectId, int userId) async {
    try {
      final access = await remoteDataSource.addUserToProject(projectId, userId);
      return Right(access);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to add user to project: $e"));
    }
  }

  @override
  Future<Either<Failure, List<ProjectUserAccessEntity>>> getProjectUsers(
      int projectId) async {
    try {
      final users = await remoteDataSource.getProjectUsers(projectId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: "Failed to get project users: $e"));
    }
  }

  @override
  Future<Either<Failure, bool>> removeUserFromProject(
      int projectId, int userId) async {
    try {
      final success =
          await remoteDataSource.removeUserFromProject(projectId, userId);
      return Right(success);
    } catch (e) {
      return Left(
          ServerFailure(message: "Failed to remove user from project: $e"));
    }
  }
}
