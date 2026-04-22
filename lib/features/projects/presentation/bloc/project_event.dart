part of 'project_bloc.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectLoadRequested extends ProjectEvent {
  final int currentUserId;
  final bool isAdmin;
  final int? preferredProjectId;

  ProjectLoadRequested({
    required this.currentUserId,
    required this.isAdmin,
    this.preferredProjectId,
  });

  @override
  List<Object?> get props => [currentUserId, isAdmin, preferredProjectId];
}

class ProjectSelected extends ProjectEvent {
  final int projectId;

  ProjectSelected({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ProjectCreateRequested extends ProjectEvent {
  final String name;
  final String? description;

  ProjectCreateRequested({required this.name, this.description});

  @override
  List<Object?> get props => [name, description];
}

class ProjectUpdateRequested extends ProjectEvent {
  final int projectId;
  final String name;
  final String? description;

  ProjectUpdateRequested({
    required this.projectId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [projectId, name, description];
}

class ProjectDeleteRequested extends ProjectEvent {
  final int projectId;

  ProjectDeleteRequested({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ProjectAddUserRequested extends ProjectEvent {
  final int projectId;
  final int userId;

  ProjectAddUserRequested({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

class ProjectRemoveUserRequested extends ProjectEvent {
  final int projectId;
  final int userId;

  ProjectRemoveUserRequested({required this.projectId, required this.userId});

  @override
  List<Object?> get props => [projectId, userId];
}

class ProjectNoticeCleared extends ProjectEvent {}
