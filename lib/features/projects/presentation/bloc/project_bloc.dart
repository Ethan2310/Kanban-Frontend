import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';
import 'package:kanban_frontend/features/projects/domain/entities/project_user_summary_entity.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/add_user_to_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/create_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/delete_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/list_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/list_project_users.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/remove_user_from_project_usecase.dart';
import 'package:kanban_frontend/features/projects/domain/usecases/update_project_usecase.dart';

part 'project_event.dart';
part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ListProjectUsecase listProjectUsecase;
  final CreateProjectUsecase createProjectUsecase;
  final UpdateProjectUsecase updateProjectUsecase;
  final DeleteProjectUsecase deleteProjectUsecase;
  final AddUserToProjectUsecase addUserToProjectUsecase;
  final RemoveUserFromProjectUsecase removeUserFromProjectUsecase;
  final ListProjectUsers listProjectUsersUsecase;

  ProjectBloc({
    required this.listProjectUsecase,
    required this.createProjectUsecase,
    required this.updateProjectUsecase,
    required this.deleteProjectUsecase,
    required this.addUserToProjectUsecase,
    required this.removeUserFromProjectUsecase,
    required this.listProjectUsersUsecase,
  }) : super(ProjectInitial()) {
    on<ProjectLoadRequested>(_onLoadRequested);
    on<ProjectSelected>(_onProjectSelected);
    on<ProjectCreateRequested>(_onProjectCreateRequested);
    on<ProjectUpdateRequested>(_onProjectUpdateRequested);
    on<ProjectDeleteRequested>(_onProjectDeleteRequested);
    on<ProjectAddUserRequested>(_onProjectAddUserRequested);
    on<ProjectRemoveUserRequested>(_onProjectRemoveUserRequested);
    on<ProjectNoticeCleared>(_onProjectNoticeCleared);
  }

  Future<void> _onLoadRequested(
    ProjectLoadRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());

    final result = await listProjectUsecase(
      ListProjectParams(
        userId: event.isAdmin ? null : event.currentUserId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          ProjectError(
            message: _mapFailure(failure),
            type: _mapErrorType(failure),
          ),
        );
      },
      (projectList) async {
        final projects = projectList.projects;
        final selectedProjectId =
            _resolveSelectedProjectId(projects, event.preferredProjectId);

        var users = const <ProjectUserSummaryEntity>[];
        if (event.isAdmin && selectedProjectId != null) {
          final userResult = await listProjectUsersUsecase(
            ListProjectUsersParams(projectId: selectedProjectId),
          );
          userResult.fold(
            (_) => users = const <ProjectUserSummaryEntity>[],
            (value) => users = value.users,
          );
        }

        emit(
          ProjectLoaded(
            projects: projects,
            selectedProjectId: selectedProjectId,
            selectedProjectUsers: users,
            isAdmin: event.isAdmin,
            currentUserId: event.currentUserId,
          ),
        );
      },
    );
  }

  Future<void> _onProjectSelected(
    ProjectSelected event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (currentState.selectedProjectId == event.projectId) {
      return;
    }

    if (!currentState.isAdmin) {
      emit(currentState.copyWith(selectedProjectId: event.projectId));
      return;
    }

    emit(
      currentState.copyWith(
        selectedProjectId: event.projectId,
        isBusy: true,
        notice: null,
      ),
    );

    final result = await listProjectUsersUsecase(
      ListProjectUsersParams(projectId: event.projectId),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            selectedProjectId: event.projectId,
            selectedProjectUsers: const <ProjectUserSummaryEntity>[],
            isBusy: false,
            notice: _mapFailure(failure),
          ),
        );
      },
      (userList) {
        emit(
          currentState.copyWith(
            selectedProjectId: event.projectId,
            selectedProjectUsers: userList.users,
            isBusy: false,
            notice: null,
          ),
        );
      },
    );
  }

  Future<void> _onProjectCreateRequested(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await createProjectUsecase(
      CreateProjectParams(
        name: event.name,
        description: event.description,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (project) async {
        await _refreshLoadedState(
          emit,
          currentState,
          preferredProjectId: project.id,
          notice: 'Project created successfully.',
        );
      },
    );
  }

  Future<void> _onProjectUpdateRequested(
    ProjectUpdateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await updateProjectUsecase(
      UpdateProjectParams(
        projectId: event.projectId,
        newName: event.name,
        newDescription: event.description,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        await _refreshLoadedState(
          emit,
          currentState,
          preferredProjectId: event.projectId,
          notice: 'Project updated successfully.',
        );
      },
    );
  }

  Future<void> _onProjectDeleteRequested(
    ProjectDeleteRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await deleteProjectUsecase(
      DeleteProjectParams(projectId: event.projectId),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        await _refreshLoadedState(
          emit,
          currentState,
          notice: 'Project deleted successfully.',
        );
      },
    );
  }

  Future<void> _onProjectAddUserRequested(
    ProjectAddUserRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await addUserToProjectUsecase(
      AddUserToProjectParams(
        projectId: event.projectId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        await _refreshLoadedState(
          emit,
          currentState,
          preferredProjectId: event.projectId,
          notice: 'User added to project.',
        );
      },
    );
  }

  Future<void> _onProjectRemoveUserRequested(
    ProjectRemoveUserRequested event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProjectLoaded) {
      return;
    }

    if (!_isAdmin(currentState, emit)) {
      return;
    }

    emit(currentState.copyWith(isBusy: true, notice: null));

    final result = await removeUserFromProjectUsecase(
      RemoveUserFromProjectParams(
        projectId: event.projectId,
        userId: event.userId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
            currentState.copyWith(isBusy: false, notice: _mapFailure(failure)));
      },
      (_) async {
        await _refreshLoadedState(
          emit,
          currentState,
          preferredProjectId: event.projectId,
          notice: 'User removed from project.',
        );
      },
    );
  }

  Future<void> _onProjectNoticeCleared(
    ProjectNoticeCleared event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProjectLoaded && currentState.notice != null) {
      emit(currentState.copyWith(notice: null));
    }
  }

  bool _isAdmin(ProjectLoaded state, Emitter<ProjectState> emit) {
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

  Future<void> _refreshLoadedState(
    Emitter<ProjectState> emit,
    ProjectLoaded currentState, {
    int? preferredProjectId,
    String? notice,
  }) async {
    final result = await listProjectUsecase(
      ListProjectParams(
        userId: currentState.isAdmin ? null : currentState.currentUserId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(
          currentState.copyWith(
            isBusy: false,
            notice: _mapFailure(failure),
          ),
        );
      },
      (projectList) async {
        final projects = projectList.projects;
        final selectedProjectId = _resolveSelectedProjectId(
          projects,
          preferredProjectId ?? currentState.selectedProjectId,
        );

        var users = const <ProjectUserSummaryEntity>[];
        var resolvedNotice = notice;

        if (currentState.isAdmin && selectedProjectId != null) {
          final userResult = await listProjectUsersUsecase(
            ListProjectUsersParams(projectId: selectedProjectId),
          );

          userResult.fold(
            (failure) {
              users = const <ProjectUserSummaryEntity>[];
              resolvedNotice = _mapFailure(failure);
            },
            (value) => users = value.users,
          );
        }

        emit(
          ProjectLoaded(
            projects: projects,
            selectedProjectId: selectedProjectId,
            selectedProjectUsers: users,
            isAdmin: currentState.isAdmin,
            currentUserId: currentState.currentUserId,
            isBusy: false,
            notice: resolvedNotice,
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

  ProjectErrorType _mapErrorType(Failure failure) {
    if (failure is UnauthorizedFailure) {
      return ProjectErrorType.unauthorized;
    }
    if (failure is NotFoundFailure) {
      return ProjectErrorType.notFound;
    }
    if (failure is ServerFailure) {
      return ProjectErrorType.server;
    }
    return ProjectErrorType.generic;
  }
}
