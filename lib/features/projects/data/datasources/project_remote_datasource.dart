import 'package:dio/dio.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/features/projects/data/models/project_model.dart';
import 'package:kanban_frontend/features/projects/data/models/project_user_access_model.dart';
import 'package:kanban_frontend/features/projects/data/models/project_user_summary_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> createProject(String name, String? description);
  Future<void> deleteProject(int projectId);
  Future<ProjectModel> updateProject(
      int projectId, String newName, String? newDescription);
  Future<ProjectListModel> getProjects(int? boardId, int? userId, String? name);
  Future<ProjectUserAccessModel> addUserToProject(int projectId, int userId);
  Future<ProjectUserListModel> getProjectUsers(int projectId);
  Future<bool> removeUserFromProject(int projectId, int userId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final Dio dio;

  static const _projectEndpoints = '/api/projects';

  ProjectRemoteDataSourceImpl({required this.dio});

  String? _detail(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['detail'] as String?;
    return null;
  }

  String? _errorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['errorCode'] as String?;
    return null;
  }

  Never _mapException(DioException e, String fallback) {
    final status = e.response?.statusCode;
    if (status == 401) {
      throw UnauthorizedException(message: _detail(e) ?? 'Unauthorized.');
    }
    if (status == 404) {
      throw NotFoundException(message: _detail(e) ?? 'Resource not found.');
    }
    throw ServerException(
      message: _detail(e) ?? fallback,
      errorCode: _errorCode(e),
    );
  }

  @override
  Future<ProjectModel> createProject(String name, String? description) async {
    try {
      final response = await dio.post(_projectEndpoints, data: {
        'name': name,
        'description': description,
      });
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to create project.');
    }
  }

  @override
  Future<void> deleteProject(int projectId) async {
    try {
      await dio.delete('$_projectEndpoints/$projectId');
    } on DioException catch (e) {
      _mapException(e, 'Failed to delete project.');
    }
  }

  @override
  Future<ProjectModel> updateProject(
      int projectId, String newName, String? newDescription) async {
    try {
      final response = await dio.patch('$_projectEndpoints/$projectId', data: {
        'name': newName,
        'description': newDescription,
      });
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to update project.');
    }
  }

  @override
  Future<ProjectListModel> getProjects(
      int? boardId, int? userId, String? name) async {
    try {
      final queryParams = <String, dynamic>{};
      if (boardId != null) queryParams['boardId'] = boardId;
      if (userId != null) queryParams['userId'] = userId;
      if (name != null) queryParams['name'] = name;

      final response = await dio.get(
        _projectEndpoints,
        queryParameters: queryParams,
      );
      return ProjectListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to fetch projects.');
    }
  }

  @override
  Future<ProjectUserAccessModel> addUserToProject(
      int projectId, int userId) async {
    try {
      final response = await dio.post(
        '$_projectEndpoints/$projectId/users',
        data: {'projectId': projectId, 'userId': userId},
      );
      return ProjectUserAccessModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to add user to project.');
    }
  }

  @override
  Future<ProjectUserListModel> getProjectUsers(int projectId) async {
    try {
      final response = await dio.get('$_projectEndpoints/$projectId/users');
      return ProjectUserListModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to fetch project users.');
    }
  }

  @override
  Future<bool> removeUserFromProject(int projectId, int userId) async {
    try {
      await dio.delete('$_projectEndpoints/$projectId/users/$userId');
      return true;
    } on DioException catch (e) {
      _mapException(e, 'Failed to remove user from project.');
    }
  }
}
