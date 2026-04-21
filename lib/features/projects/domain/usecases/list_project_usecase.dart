import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/repositories/project_repository.dart';

class ListProjectUsecase
    implements UseCase<ProjectListEntity, ListProjectParams> {
  final ProjectRepository repository;

  ListProjectUsecase(this.repository);

  @override
  Future<Either<Failure, ProjectListEntity>> call(
      ListProjectParams params) async {
    return await repository.getProjects(
        params.boardId, params.userId, params.name);
  }
}

class ListProjectParams {
  final int? boardId;
  final int? userId;
  final String? name;

  ListProjectParams({this.boardId, this.userId, this.name});
}
