import 'package:kanban_frontend/features/projects/domain/entities/project_user_access_entity.dart';

class ProjectUserAccessModel extends ProjectUserAccessEntity {
  const ProjectUserAccessModel({
    required super.projectId,
    required super.userId,
  });

  factory ProjectUserAccessModel.fromJson(Map<String, dynamic> json) {
    return ProjectUserAccessModel(
      projectId: json['projectId'] as int,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectId': projectId,
      'userId': userId,
    };
  }
}
