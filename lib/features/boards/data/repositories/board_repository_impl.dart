import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/boards/data/datasources/board_remote_datasource.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/domain/repositories/board_repository.dart';

class BoardRepositoryImpl implements BoardRepository {
  final BoardRemoteDataSource remoteDataSource;

  BoardRepositoryImpl({required this.remoteDataSource});

  Failure _mapException(Object e) {
    if (e is UnauthorizedException) {
      return UnauthorizedFailure(message: e.message);
    }
    if (e is NotFoundException) {
      return NotFoundFailure(message: e.message);
    }
    if (e is ServerException) {
      return ServerFailure(message: e.message, errorCode: e.errorCode);
    }
    return ServerFailure(message: e.toString());
  }

  @override
  Future<Either<Failure, BoardEntity>> createBoard(
    String name,
    String? description,
    int projectId,
  ) async {
    try {
      final board =
          await remoteDataSource.createBoard(name, description, projectId);
      return Right(board);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, BoardEntity>> updateBoard(
    int boardId,
    String? name,
    String? description,
  ) async {
    try {
      final board =
          await remoteDataSource.updateBoard(boardId, name, description);
      return Right(board);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBoard(int boardId) async {
    try {
      final success = await remoteDataSource.deleteBoard(boardId);
      return Right(success);
    } catch (e) {
      return Left(_mapException(e));
    }
  }

  @override
  Future<Either<Failure, BoardListEntity>> getBoards(
      int projectId, String? name) async {
    try {
      final boards = await remoteDataSource.getBoards(projectId, name);
      return Right(boards);
    } catch (e) {
      return Left(_mapException(e));
    }
  }
}
