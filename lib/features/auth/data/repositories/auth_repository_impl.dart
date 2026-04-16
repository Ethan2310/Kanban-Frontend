import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/exceptions.dart';
import 'package:kanban_frontend/core/error/failures.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_local_secure_storage.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kanban_frontend/features/auth/domain/entities/user_entity.dart';
import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final AuthLocalSecureStorage authLocalSecureStorage;
  final AuthLocalDataSource authLocalDataSource;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.authLocalSecureStorage,
    required this.authLocalDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final (:token, :user) = await authRemoteDataSource.login(
        email: email,
        password: password,
      );
      await authLocalSecureStorage.cacheToken(token);
      await authLocalDataSource.cacheUser(user);
      return Right(user);
    } on InvalidCredentialsException catch (e) {
      return Left(InvalidCredentialsFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
  }) async {
    try {
      final user = await authRemoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: role,
      );
      await authLocalDataSource.cacheUser(user);
      return Right(user);
    } on ConflictException catch (e) {
      return Left(ConflictFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, errorCode: e.errorCode));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await authLocalDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await authLocalSecureStorage.clearToken();
      await authLocalDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (_) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await authLocalSecureStorage.getCachedToken();
      return Right(token != null);
    } on CacheException catch (_) {
      return const Left(CacheFailure());
    }
  }
}
