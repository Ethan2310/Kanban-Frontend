import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/domain/repositories/board_repository.dart';

class UpdateBoardUsecase implements UseCase<BoardEntity, UpdateBoardParams> {
  final BoardRepository repository;

  UpdateBoardUsecase(this.repository);

  @override
  Future<Either<Failure, BoardEntity>> call(UpdateBoardParams params) {
    return repository.updateBoard(
      params.boardId,
      params.name,
      params.description,
    );
  }
}

class UpdateBoardParams {
  final int boardId;
  final String? name;
  final String? description;

  UpdateBoardParams({
    required this.boardId,
    this.name,
    this.description,
  });
}
