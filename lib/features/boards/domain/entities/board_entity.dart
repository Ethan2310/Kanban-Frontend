import 'package:equatable/equatable.dart';
import 'package:kanban_frontend/core/entities/base_entity.dart';

class BoardEntity extends Equatable {
  final int id;
  final String name;
  final String? description;

  const BoardEntity({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, description];
}

class BoardListEntity extends BasePaginatedEntity {
  final List<BoardEntity> boards;

  const BoardListEntity({
    required this.boards,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  @override
  List<Object?> get props => [...super.props, boards];
}
