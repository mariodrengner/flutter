class AuthResult {
  AuthResult({
    required this.success,
    this.userId,
    this.email,
    this.errorMessage,
  });

  final bool success;
  final String? userId;
  final String? email;
  final String? errorMessage;
}
