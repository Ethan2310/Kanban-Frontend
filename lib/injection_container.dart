import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:kanban_frontend/core/network/dio_client.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_local_secure_storage.dart';
import 'package:kanban_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:kanban_frontend/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:kanban_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/get_current_user.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/login_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/register_usecase.dart';
import 'package:kanban_frontend/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kanban_frontend/features/auth/presentation/bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env.local');
  }

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      logOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      checkAuthUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => LoginUseCase(repository: sl()));
  sl.registerLazySingleton(() => RegisterUseCase(repository: sl()));
  sl.registerLazySingleton(() => LogOutUseCase(repository: sl()));
  sl.registerLazySingleton(() => AuthCheckUseCase(repository: sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(repository: sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      authRemoteDataSource: sl(),
      authLocalSecureStorage: sl(),
      authLocalDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<AuthLocalSecureStorage>(
    () => AuthLocalSecureStorageImpl(secureStorage: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  const flutterSecureStorage = FlutterSecureStorage();
  final dio = DioClient.create();

  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => flutterSecureStorage);
}
