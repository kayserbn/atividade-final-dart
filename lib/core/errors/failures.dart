sealed class Failure {
  final String message;
  const Failure(this.message);
}

final class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
