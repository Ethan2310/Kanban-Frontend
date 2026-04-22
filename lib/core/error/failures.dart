import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  const Failure({this.message});

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  final String? errorCode;
  const ServerFailure({super.message, this.errorCode});

  @override
  List<Object?> get props => [...super.props, errorCode];
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({super.message});
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.message});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.message});
}
