import 'package:dio/dio.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/features/auth/data/models/user_model.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  /// Returns a record of (token, user) on success.
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  });

  /// Returns the created [UserModel] on success.
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  static const _loginEndpoint = '/api/auth/login';
  static const _registerEndpoint = '/api/auth/register';

  AuthRemoteDataSourceImpl({required this.dio});

  // Extracts the human-readable detail from a backend error response.
  String? _detail(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['detail'] as String?;
    return null;
  }

  // Extracts the machine-readable error_code from a backend error response.
  String? _errorCode(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) return data['error_code'] as String?;
    return null;
  }

  String _networkHint(DioException e) {
    final errorMessage = (e.message ?? '').toLowerCase();

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Request timed out. Make sure the API server is running and reachable.';
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      if (errorMessage.contains('xmlhttprequest') ||
          errorMessage.contains('cors')) {
        return 'Request blocked by browser (CORS) or API is unreachable. Allow your web origin in backend CORS and verify BASE_URL.';
      }

      return 'Unable to connect to API. Make sure the backend is running and BASE_URL is correct.';
    }

    return 'Unexpected server communication error.';
  }

  @override
  Future<({String token, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        _loginEndpoint,
        data: {'email': email, 'password': password},
      );

      final token = response.data['token'] as String;
      final user = UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
      return (token: token, user: user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsException(message: _detail(e));
      }
      throw ServerException(
        message: _detail(e) ?? _networkHint(e),
        errorCode: _errorCode(e),
      );
    } catch (_) {
      throw const ServerException();
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      final response = await dio.post(
        _registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'role': role.name,
        },
      );

      return UserModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw ConflictException(message: _detail(e));
      }
      throw ServerException(
        message: _detail(e) ?? _networkHint(e),
        errorCode: _errorCode(e),
      );
    } catch (_) {
      throw const ServerException();
    }
  }
}
