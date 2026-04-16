class ServerException implements Exception {
  final String? message;
  final String? errorCode;
  const ServerException({this.message, this.errorCode});
}

class CacheException implements Exception {
  const CacheException();
}

class InvalidCredentialsException implements Exception {
  final String? message;
  const InvalidCredentialsException({this.message});
}

class ConflictException implements Exception {
  final String? message;
  const ConflictException({this.message});
}