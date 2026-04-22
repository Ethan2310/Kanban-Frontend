part of 'project_bloc.dart';

enum ProjectErrorType { generic, unauthorized, notFound, server }

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<ProjectEntity> projects;
  final int? selectedProjectId;
  final List<ProjectUserSummaryEntity> selectedProjectUsers;
  final bool isAdmin;
  final int currentUserId;
  final bool isBusy;
  final String? notice;

  ProjectLoaded({
    required this.projects,
    required this.selectedProjectId,
    required this.selectedProjectUsers,
    required this.isAdmin,
    required this.currentUserId,
    this.isBusy = false,
    this.notice,
  });

  ProjectEntity? get selectedProject {
    if (selectedProjectId == null) {
      return null;
    }

    for (final project in projects) {
      if (project.id == selectedProjectId) {
        return project;
      }
    }

    return null;
  }

  ProjectLoaded copyWith({
    List<ProjectEntity>? projects,
    int? selectedProjectId,
    List<ProjectUserSummaryEntity>? selectedProjectUsers,
    bool? isAdmin,
    int? currentUserId,
    bool? isBusy,
    String? notice,
  }) {
    return ProjectLoaded(
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      selectedProjectUsers: selectedProjectUsers ?? this.selectedProjectUsers,
      isAdmin: isAdmin ?? this.isAdmin,
      currentUserId: currentUserId ?? this.currentUserId,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
        projects,
        selectedProjectId,
        selectedProjectUsers,
        isAdmin,
        currentUserId,
        isBusy,
        notice,
      ];
}

class ProjectError extends ProjectState {
  final String message;
  final ProjectErrorType type;

  ProjectError({required this.message, this.type = ProjectErrorType.generic});

  @override
  List<Object?> get props => [message, type];
}
