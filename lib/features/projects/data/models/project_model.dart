import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      // Supports both {id: ...} and {projectId: ...} payloads.
      id: (json['id'] ?? json['projectId']) as int,
      name: (json['name'] as String?) ?? '',
      description: (json['description'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class ProjectListModel extends ProjectListEntity {
  const ProjectListModel({
    required super.projects,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  factory ProjectListModel.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return ProjectListModel(
      projects: (json['projects'] as List)
          .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: pagination['totalCount'] as int,
      pageSize: pagination['pageSize'] as int,
      pageNumber: pagination['pageNumber'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projects': projects.map((e) => (e as ProjectModel).toJson()).toList(),
      'pagination': {
        'totalCount': totalCount,
        'pageSize': pageSize,
        'pageNumber': pageNumber,
        'totalPages': totalPages,
      },
    };
  }
}
