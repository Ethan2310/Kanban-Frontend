import 'package:dio/dio.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/features/boards/data/models/board_model.dart';

abstract class BoardRemoteDataSource {
  Future<BoardModel> createBoard(
      String name, String? description, int projectId);
  Future<BoardModel> updateBoard(
      int boardId, String? name, String? description);
  Future<bool> deleteBoard(int boardId);
  Future<BoardListModel> getBoards(int projectId, String? name);
}

class BoardRemoteDataSourceImpl implements BoardRemoteDataSource {
  final Dio dio;

  static const _boardEndpoint = '/api/boards';

  BoardRemoteDataSourceImpl({required this.dio});

  String? _detail(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['detail'] as String?;
    }
    return null;
  }

  String? _errorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['errorCode'] as String?;
    }
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
  Future<BoardModel> createBoard(
    String name,
    String? description,
    int projectId,
  ) async {
    try {
      final response = await dio.post(
        _boardEndpoint,
        data: {
          'name': name,
          'description': description,
          'projectId': projectId,
        },
      );

      return BoardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to create board.');
    }
  }

  @override
  Future<BoardModel> updateBoard(
    int boardId,
    String? name,
    String? description,
  ) async {
    try {
      final response = await dio.patch(
        '$_boardEndpoint/$boardId',
        data: {
          'name': name,
          'description': description,
        },
      );

      return BoardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to update board.');
    }
  }

  @override
  Future<bool> deleteBoard(int boardId) async {
    try {
      final response = await dio.delete('$_boardEndpoint/$boardId');
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['success'] as bool? ?? true;
      }
      return true;
    } on DioException catch (e) {
      _mapException(e, 'Failed to delete board.');
    }
  }

  @override
  Future<BoardListModel> getBoards(int projectId, String? name) async {
    try {
      final queryParams = <String, dynamic>{
        'projectId': projectId,
      };

      if (name != null && name.trim().isNotEmpty) {
        queryParams['name'] = name;
      }

      final response = await dio.get(
        _boardEndpoint,
        queryParameters: queryParams,
      );

      return BoardListModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _mapException(e, 'Failed to fetch boards.');
    }
  }
}
