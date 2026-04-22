import 'package:equatable/equatable.dart';
import 'package:kanban_frontend/core/entities/base_entity.dart';

class ProjectEntity extends Equatable {
  final int id;
  final String name;
  final String description;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
      ];
}

class ProjectListEntity extends BasePaginatedEntity {
  final List<ProjectEntity> projects;

  const ProjectListEntity({
    required this.projects,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        projects,
      ];
}
