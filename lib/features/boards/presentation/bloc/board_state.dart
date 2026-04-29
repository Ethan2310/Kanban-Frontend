part of 'board_bloc.dart';

enum BoardErrorType { generic, unauthorized, notFound, server }

abstract class BoardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BoardInitial extends BoardState {}

class BoardLoading extends BoardState {}

class BoardLoaded extends BoardState {
  final List<ProjectEntity> projects;
  final int? selectedProjectId;
  final List<BoardEntity> boards;
  final int currentUserId;
  final bool isAdmin;
  final bool isBusy;
  final String? notice;

  BoardLoaded({
    required this.projects,
    required this.selectedProjectId,
    required this.boards,
    required this.currentUserId,
    required this.isAdmin,
    this.isBusy = false,
    this.notice,
  });

  BoardLoaded copyWith({
    List<ProjectEntity>? projects,
    int? selectedProjectId,
    List<BoardEntity>? boards,
    int? currentUserId,
    bool? isAdmin,
    bool? isBusy,
    String? notice,
  }) {
    return BoardLoaded(
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      boards: boards ?? this.boards,
      currentUserId: currentUserId ?? this.currentUserId,
      isAdmin: isAdmin ?? this.isAdmin,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
    );
  }

  @override
  List<Object?> get props => [
        projects,
        selectedProjectId,
        boards,
        currentUserId,
        isAdmin,
        isBusy,
        notice,
      ];
}

class BoardError extends BoardState {
  final String message;
  final BoardErrorType type;

  BoardError({required this.message, this.type = BoardErrorType.generic});

  @override
  List<Object?> get props => [message, type];
}
