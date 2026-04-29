import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';

abstract class BoardRepository {
  Future<Either<Failure, BoardEntity>> createBoard(
    String name,
    String? description,
    int projectId,
  );

  Future<Either<Failure, BoardEntity>> updateBoard(
    int boardId,
    String? name,
    String? description,
  );

  Future<Either<Failure, bool>> deleteBoard(int boardId);

  Future<Either<Failure, BoardListEntity>> getBoards(
      int projectId, String? name);
}
