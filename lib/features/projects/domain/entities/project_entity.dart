import 'package:kanban_frontend/core/entities/base_entity.dart';

class ProjectEntity extends BaseEntity {
  final String name;
  final String description;

  const ProjectEntity({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required this.name,
    required this.description,
  });

  @override
  List<Object?> get props => [
        ...super.props,
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
    required super.currentPage,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        projects,
      ];
}
