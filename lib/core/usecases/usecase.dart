import 'package:dartz/dartz.dart';
import 'package:kanban_frontend/core/error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
