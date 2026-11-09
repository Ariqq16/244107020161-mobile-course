import '../entities/user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final User user;
  final String accessToken;
  final String refreshToken;
}

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

abstract class AuthRepository {
  Future<AuthSession> login({
    required String username,
    required String password,
  });
  Future<AuthTokens> refresh(String refreshToken);
  Future<User?> restoreSession();
  Future<void> logout();
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({required String access, required String refresh});
}
