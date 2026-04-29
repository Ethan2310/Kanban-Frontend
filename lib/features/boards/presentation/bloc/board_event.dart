part of 'board_bloc.dart';

abstract class BoardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BoardLoadRequested extends BoardEvent {
  final int currentUserId;
  final bool isAdmin;
  final int? preferredProjectId;

  BoardLoadRequested({
    required this.currentUserId,
    required this.isAdmin,
    this.preferredProjectId,
  });

  @override
  List<Object?> get props => [currentUserId, isAdmin, preferredProjectId];
}

class BoardProjectSelected extends BoardEvent {
  final int projectId;

  BoardProjectSelected({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class BoardCreateRequested extends BoardEvent {
  final String name;
  final String? description;
  final int projectId;

  BoardCreateRequested({
    required this.name,
    this.description,
    required this.projectId,
  });

  @override
  List<Object?> get props => [name, description, projectId];
}

class BoardUpdateRequested extends BoardEvent {
  final int boardId;
  final String name;
  final String? description;

  BoardUpdateRequested({
    required this.boardId,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [boardId, name, description];
}

class BoardDeleteRequested extends BoardEvent {
  final int boardId;

  BoardDeleteRequested({required this.boardId});

  @override
  List<Object?> get props => [boardId];
}

class BoardNoticeCleared extends BoardEvent {}
