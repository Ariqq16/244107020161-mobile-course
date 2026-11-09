import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/token_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
  });

  final AuthRemoteDataSource remote;
  final TokenLocalDataSource local;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final result = await remote.login(username: username, password: password);
    await local.saveTokens(
      access: result.tokens.access,
      refresh: result.tokens.refresh,
    );
    await local.saveUser(result.user);
    return AuthSession(
      user: result.user,
      accessToken: result.tokens.access,
      refreshToken: result.tokens.refresh,
    );
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    final tokens = await remote.refresh(refreshToken);
    await local.saveTokens(access: tokens.access, refresh: tokens.refresh);
    return AuthTokens(access: tokens.access, refresh: tokens.refresh);
  }

  @override
  Future<User?> restoreSession() async {
    final access = await local.readAccess();
    if (access == null || access.isEmpty) return null;
    return local.readUser();
  }

  @override
  Future<void> logout() => local.clear();

  @override
  Future<String?> readAccessToken() => local.readAccess();

  @override
  Future<String?> readRefreshToken() => local.readRefresh();

  @override
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) =>
      local.saveTokens(access: access, refresh: refresh);
}
