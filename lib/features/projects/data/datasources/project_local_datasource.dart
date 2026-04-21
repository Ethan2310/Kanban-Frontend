import 'package:kanban_frontend/features/projects/data/models/project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ProjectLocalDataSource {
  Future<void> cacheProjects(ProjectListModel projects);
  Future<ProjectListModel> getCachedProjects();
  Future<void> clearCache();
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const _projectKey = 'CACHED_PROJECTS';
  ProjectListModel _cachedProjects = const ProjectListModel(
      projects: [], totalCount: 0, pageSize: 0, currentPage: 0);

  ProjectLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProjects(ProjectListModel projects) async {
    _cachedProjects = projects;
    final projectsJson = projects.toJson()['projects'] as List<dynamic>;
    await sharedPreferences.setString(_projectKey, projectsJson.toString());
  }

  @override
  Future<ProjectListModel> getCachedProjects() async {
    final cachedString = sharedPreferences.getString(_projectKey);
    if (cachedString != null) {
      final List<dynamic> projectsJson = cachedString as List<dynamic>;
      _cachedProjects = ProjectListModel(
        projects:
            projectsJson.map((json) => ProjectModel.fromJson(json)).toList(),
        totalCount: projectsJson.length,
        pageSize: projectsJson.length,
        currentPage: 1,
      );
    }
    return _cachedProjects;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_projectKey);
    _cachedProjects = const ProjectListModel(
        projects: [], totalCount: 0, pageSize: 0, currentPage: 0);
  }
}
