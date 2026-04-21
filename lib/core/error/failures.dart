import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String? message;
  const Failure(String s, {this.message});

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
  const CacheFailure() : super();
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({super.message});
}

class ConflictFailure extends Failure {
  const ConflictFailure({super.message});
}
