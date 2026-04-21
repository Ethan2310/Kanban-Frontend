import 'package:kanban_frontend/core/entities/base_entity.dart';

class ProjectUserAccessEntity extends BaseEntity {
  final String projectId;
  final String userId;

  const ProjectUserAccessEntity({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required this.projectId,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        ...super.props,
        projectId,
        userId,
      ];
}
