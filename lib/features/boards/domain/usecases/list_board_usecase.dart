import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/core/usecases/usecase.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/domain/repositories/board_repository.dart';

class ListBoardUsecase implements UseCase<BoardListEntity, ListBoardParams> {
  final BoardRepository repository;

  ListBoardUsecase(this.repository);

  @override
  Future<Either<Failure, BoardListEntity>> call(ListBoardParams params) {
    return repository.getBoards(params.projectId, params.name);
  }
}

class ListBoardParams {
  final int projectId;
  final String? name;

  ListBoardParams({required this.projectId, this.name});
}
