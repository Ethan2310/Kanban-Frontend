import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/domain/repositories/board_repository.dart';

class CreateBoardUsecase implements UseCase<BoardEntity, CreateBoardParams> {
  final BoardRepository repository;

  CreateBoardUsecase(this.repository);

  @override
  Future<Either<Failure, BoardEntity>> call(CreateBoardParams params) {
    return repository.createBoard(
      params.name,
      params.description,
      params.projectId,
    );
  }
}

class CreateBoardParams {
  final String name;
  final String? description;
  final int projectId;

  CreateBoardParams({
    required this.name,
    this.description,
    required this.projectId,
  });
}
