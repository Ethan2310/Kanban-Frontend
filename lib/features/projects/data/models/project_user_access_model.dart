import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';

class ProjectUserAccessModel extends ProjectUserAccessEntity {
  const ProjectUserAccessModel({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required super.projectId,
    required super.userId,
  });

  factory ProjectUserAccessModel.fromJson(Map<String, dynamic> json) {
    return ProjectUserAccessModel(
      id: json['id'],
      guid: json['guid'],
      createdById: json['createdById'],
      createdOn: DateTime.parse(json['createdOn']),
      updatedById: json['updatedById'],
      updatedOn: DateTime.parse(json['updatedOn']),
      isActive: json['isActive'],
      projectId: json['projectId'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guid': guid,
      'createdById': createdById,
      'createdOn': createdOn.toIso8601String(),
      'updatedById': updatedById,
      'updatedOn': updatedOn.toIso8601String(),
      'isActive': isActive,
      'projectId': projectId,
      'userId': userId,
    };
  }
}
