import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const authTokenStorageKey = 'AUTH_TOKEN';

abstract class AuthLocalSecureStorage {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();
}

class AuthLocalSecureStorageImpl implements AuthLocalSecureStorage {
  final FlutterSecureStorage secureStorage;

  AuthLocalSecureStorageImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: authTokenStorageKey, value: token);
  }

  @override
  Future<String?> getCachedToken() async {
    return await secureStorage.read(key: authTokenStorageKey);
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: authTokenStorageKey);
  }
}
