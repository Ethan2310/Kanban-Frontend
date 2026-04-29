import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/boards/domain/entities/board_entity.dart';
import 'package:kanban_frontend/features/boards/domain/usecases/create_board_usecase.dart';
import 'package:kanban_frontend/features/boards/domain/usecases/delete_board_usecase.dart';
import 'package:kanban_frontend/features/boards/domain/usecases/list_board_usecase.dart';
import 'package:kanban_frontend/features/boards/domain/usecases/update_board_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/list_project_usecase.dart';

part 'board_event.dart';
part 'board_state.dart';

class BoardBloc extends Bloc<BoardEvent, BoardState> {
  final ListProjectUsecase listProjectUsecase;
  final ListBoardUsecase listBoardUsecase;
  final CreateBoardUsecase createBoardUsecase;
  final UpdateBoardUsecase updateBoardUsecase;
  final DeleteBoardUsecase deleteBoardUsecase;

  BoardBloc({
    required this.listProjectUsecase,
    required this.listBoardUsecase,
    required this.createBoardUsecase,
    required this.updateBoardUsecase,
    required this.deleteBoardUsecase,
  }) : super(BoardInitial()) {
    on<BoardLoadRequested>(_onLoadRequested);
    on<BoardProjectSelected>(_onProjectSelected);
    on<BoardCreateRequested>(_onCreateRequested);
    on<BoardUpdateRequested>(_onUpdateRequested);
    on<BoardDeleteRequested>(_onDeleteRequested);
    on<BoardNoticeCleared>(_onNoticeCleared);
  }

  Future<void> _onLoadRequested(
    BoardLoadRequested event,
    Emitter<BoardState> emit,
  ) async {
    if (!event.isAdmin) {
      emit(
        BoardError(
          message: 'Only admins can access board management.',
          type: BoardErrorType.unauthorized,
        ),
      );
      return;
    }

    emit(BoardLoading());

    final projectsResult = await listProjectUsecase(
      ListProjectParams(userId: null),
    );

    await projectsResult.fold(
      (failure) async {
        emit(
          BoardError(
            message: _mapFailure(failure),
            type: _mapErrorType(failure),
          ),
        );
      },
      (projectList) async {
        final projects = projectList.projects;
        final selectedProjectId = _resolveSelectedProjectId(
          projects,
          event.preferredProjectId,
        );

        if (selectedProjectId == null) {
          emit(
            BoardLoaded(
              projects: projects,
              selectedProjectId: null,
              boards: const <BoardEntity>[],
              currentUserId: event.currentUserId,
              isAdmin: event.isAdmin,
            ),
          );
          return;
        }

        final boardsResult = await listBoardUsecase(
          ListBoardParams(projectId: selectedProjectId),
        );

        boardsResult.fold(
          (failure) {
            emit(
              BoardError(
                message: _mapFailure(failure),
                type: _mapErrorType(failure),
              ),
            );
          },
          (boardList) {
            emit(
              BoardLoaded(
                projects: projects,
                selectedProjectId: selectedProjectId,
                boards: boardList.boards,
                currentUserId: event.currentUserId,
                isAdmin: event.isAdmin,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onProjectSelected(
    BoardProjectSelected event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardLoaded) {
      return;
    }

    if (currentState.selectedProjectId == event.projectId) {
      return;
    }

    emit(
      currentState.copyWith(
        selectedProjectId: event.projectId,
        isBusy: true,
        notice: null,
      ),
    );

    final boardsResult = await listBoardUsecase(
      ListBoardParams(projectId: event.projectId),
    );

    boardsResult.fold(
      (failure) {
        emit(
          currentState.copyWith(
            selectedProjectId: event.projectId,
            boards: const <BoardEntity>[],
            isBusy: false,
            notice: _mapFailure(failure),
          ),
        );
      },
      (boardList) {
        emit(
          currentState.copyWith(
            selectedProjectId: event.projectId,
            boards: boardList.boards,
            isBusy: false,
            notice: null,
          ),
        );
      },
    );
  }

  Future<void> _onCreateRequested(
    BoardCreateRequested event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await createBoardUsecase(
      CreateBoardParams(
        name: event.name,
        description: event.description,
        projectId: event.projectId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        await _refreshBoards(
          emit,
          currentState,
          projectId: event.projectId,
          notice: 'Board created successfully.',
        );
      },
    );
  }

  Future<void> _onUpdateRequested(
    BoardUpdateRequested event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await updateBoardUsecase(
      UpdateBoardParams(
        boardId: event.boardId,
        name: event.name,
        description: event.description,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        final selectedProjectId = currentState.selectedProjectId;
        if (selectedProjectId == null) {
          emit(currentState.copyWith(
              isBusy: false, notice: 'No project selected.'));
          return;
        }
        await _refreshBoards(
          emit,
          currentState,
          projectId: selectedProjectId,
          notice: 'Board updated successfully.',
        );
      },
    );
  }

  Future<void> _onDeleteRequested(
    BoardDeleteRequested event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BoardLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await deleteBoardUsecase(
      DeleteBoardParams(boardId: event.boardId),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        final selectedProjectId = currentState.selectedProjectId;
        if (selectedProjectId == null) {
          emit(currentState.copyWith(
              isBusy: false, notice: 'No project selected.'));
          return;
        }
        await _refreshBoards(
          emit,
          currentState,
          projectId: selectedProjectId,
          notice: 'Board deleted successfully.',
        );
      },
    );
  }

  Future<void> _onNoticeCleared(
    BoardNoticeCleared event,
    Emitter<BoardState> emit,
  ) async {
    final currentState = state;
    if (currentState is BoardLoaded && currentState.notice != null) {
      emit(currentState.copyWith(notice: null));
    }
  }

  bool _isAdmin(BoardLoaded state, Emitter<BoardState> emit) {
    if (state.isAdmin) {
      return true;
    }

    emit(state.copyWith(notice: 'Only admins can perform this action.'));
    return false;
  }

  int? _resolveSelectedProjectId(
    List<ProjectEntity> projects,
    int? preferredProjectId,
  ) {
    if (projects.isEmpty) {
      return null;
    }

    if (preferredProjectId != null) {
      for (final project in projects) {
        if (project.id == preferredProjectId) {
          return preferredProjectId;
        }
      }
    }

    return projects.first.id;
  }

  Future<void> _refreshBoards(
    Emitter<BoardState> emit,
    BoardLoaded currentState, {
    required int projectId,
    String? notice,
  }) async {
    final result =
        await listBoardUsecase(ListBoardParams(projectId: projectId));

    result.fold(
      (failure) {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (boardList) {
        emit(
          currentState.copyWith(
            selectedProjectId: projectId,
            boards: boardList.boards,
            isBusy: false,
            notice: notice,
          ),
        );
      },
    );
  }

  String _mapFailure(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return failure.message ?? 'Unauthorized action.';
    }
    if (failure is NotFoundFailure) {
      return failure.message ?? 'Resource not found.';
    }
    if (failure is ServerFailure) {
      return failure.message ?? 'A server error occurred.';
    }
    return failure.message ?? 'An unexpected error occurred.';
  }

  BoardErrorType _mapErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return BoardErrorType.unauthorized;
    }
    if (failure is NotFoundFailure) {
      return BoardErrorType.notFound;
    }
    if (failure is ServerFailure) {
      return BoardErrorType.server;
    }
    return BoardErrorType.generic;
  }
}
