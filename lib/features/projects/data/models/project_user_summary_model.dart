import 'package:kanban_frontend/features/projects/domain/entities/project_user_summary_entity.dart';

class ProjectUserSummaryModel extends ProjectUserSummaryEntity {
  const ProjectUserSummaryModel({
    required super.userId,
    required super.firstName,
    required super.lastName,
    required super.email,
  });

  factory ProjectUserSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProjectUserSummaryModel(
      userId: json['userId'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
    );
  }
}

class ProjectUserListModel extends ProjectUserListEntity {
  const ProjectUserListModel({
    required super.users,
    required super.totalCount,
    required super.pageSize,
    required super.pageNumber,
    required super.totalPages,
  });

  factory ProjectUserListModel.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return ProjectUserListModel(
      users: (json['users'] as List)
          .map((e) =>
              ProjectUserSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: pagination['totalCount'] as int,
      pageSize: pagination['pageSize'] as int,
      pageNumber: pagination['pageNumber'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }
}
