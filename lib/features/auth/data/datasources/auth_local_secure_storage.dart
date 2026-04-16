import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalSecureStorage {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();
}

class AuthLocalSecureStorageImpl implements AuthLocalSecureStorage {
  final FlutterSecureStorage secureStorage;

  static const _tokenKey = 'AUTH_TOKEN';

  AuthLocalSecureStorageImpl({required this.secureStorage});

  @override
  Future<void> cacheToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getCachedToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await secureStorage.delete(key: _tokenKey);
  }
}
