import 'package:dio/dio.dart';
import 'package:kanban_frontend/features/projects/data/models/project_model.dart';
import 'package:kanban_frontend/features/projects/data/models/project_user_access_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject(String name, String? description);
  Future<void> deleteProject(int projectId);
  Future<ProjectModel> updateProject(
      int projectId, String newName, String? newDescription);
  Future<ProjectListModel> getProjects(int? boardId, int? userId, String? name);
  Future<ProjectUserAccessModel> addUserToProject(int projectId, int userId);
  Future<List<ProjectUserAccessModel>> getProjectUsers(int projectId);
  Future<bool> removeUserFromProject(int projectId, int userId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio dio;

  static const _projectEndpoints = '/api/projects';
  static const _projectUserAccessEndpoints = '/api/project-users';

  ProjectRemoteDataSourceImpl({required this.dio});

  @override
  Future<ProjectModel> createProject(String name, String? description) async {
    final response = await dio.post(_projectEndpoints, data: {
      'name': name,
      'description': description,
    });
    return ProjectModel.fromJson(response.data);
  }

  @override
  Future<void> deleteProject(int projectId) async {
    await dio.delete('$_projectEndpoints/$projectId');
  }

  @override
  Future<ProjectModel> updateProject(
      int projectId, String newName, String? newDescription) async {
    final response = await dio.put('$_projectEndpoints/$projectId', data: {
      'name': newName,
      'description': newDescription,
    });
    return ProjectModel.fromJson(response.data);
  }

  @override
  Future<ProjectListModel> getProjects(
      int? boardId, int? userId, String? name) async {
    final queryParams = <String, dynamic>{};
    if (boardId != null) queryParams['boardId'] = boardId;
    if (userId != null) queryParams['userId'] = userId;
    if (name != null) queryParams['name'] = name;

    final response =
        await dio.get(_projectEndpoints, queryParameters: queryParams);
    return ProjectListModel.fromJson(response.data);
  }

  @override
  Future<ProjectUserAccessModel> addUserToProject(
      int projectId, int userId) async {
    final response = await dio.post(_projectUserAccessEndpoints, data: {
      'projectId': projectId,
      'userId': userId,
    });
    return ProjectUserAccessModel.fromJson(response.data);
  }

  @override
  Future<List<ProjectUserAccessModel>> getProjectUsers(int projectId) async {
    final response =
        await dio.get('$_projectUserAccessEndpoints/$projectId/users');
    return (response.data as List)
        .map((json) => ProjectUserAccessModel.fromJson(json))
        .toList();
  }

  @override
  Future<bool> removeUserFromProject(int projectId, int userId) async {
    await dio.delete('$_projectUserAccessEndpoints/$projectId/users/$userId');
    return true;
  }
}
