class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

enum AuthErrorType {
  invalidEmail,
  weakPassword,
  emailAlreadyInUse,
  wrongPassword,
  userNotFound,
  networkError,
  unknown,
}
