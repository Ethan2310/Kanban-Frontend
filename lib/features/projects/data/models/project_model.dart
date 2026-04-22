import 'package:kanban_frontend/features/projects/domain/entities/project_entity.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.guid,
    super.createdById,
    required super.createdOn,
    super.updatedById,
    required super.updatedOn,
    required super.isActive,
    required super.name,
    required super.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      guid: json['guid'],
      createdById: json['createdById'],
      createdOn: DateTime.parse(json['createdOn']),
      updatedById: json['updatedById'],
      updatedOn: DateTime.parse(json['updatedOn']),
      isActive: json['isActive'],
      name: json['name'],
      description: json['description'],
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
          .map((e) => ProjectModel.fromJson(e))
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
