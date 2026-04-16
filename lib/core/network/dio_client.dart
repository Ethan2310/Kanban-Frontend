import 'package:dio/dio.dart';
import 'package:kanban_frontend/core/config/app_config.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }
}
