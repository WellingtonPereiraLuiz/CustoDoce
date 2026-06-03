abstract class Failure {
  final String message;
  const Failure(this.message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class PaywallFailure extends Failure {
  const PaywallFailure(super.message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
