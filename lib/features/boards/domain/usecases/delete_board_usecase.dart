import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/boards/domain/repositories/board_repository.dart';

class DeleteBoardUsecase implements UseCase<bool, DeleteBoardParams> {
  final BoardRepository repository;

  DeleteBoardUsecase(this.repository);

  @override
  Future<Either<Failure, bool>> call(DeleteBoardParams params) {
    return repository.deleteBoard(params.boardId);
  }
}

class DeleteBoardParams {
  final int boardId;

  DeleteBoardParams({required this.boardId});
}
