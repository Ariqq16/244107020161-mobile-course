import 'package:dio/dio.dart';

import '../config.dart';
import 'user_profile.dart';

class AuthTokens {
  const AuthTokens({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class LoginResult {
  const LoginResult({required this.tokens, required this.profile});
  final AuthTokens tokens;
  final UserProfile profile;
}

class AuthRepository {
  AuthRepository({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: kApiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/json'},
            ));

  final Dio _dio;

  Future<LoginResult> login({
    required String username,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': kAccessTokenMinutes,
      },
    );
    final data = res.data ?? <String, dynamic>{};
    final access = data['accessToken'] as String? ?? data['token'] as String?;
    final refresh = data['refreshToken'] as String? ?? '';
    if (access == null || access.isEmpty) {
      throw const FormatException('Respons login tidak berisi token');
    }
    return LoginResult(
      tokens: AuthTokens(access: access, refresh: refresh),
      profile: UserProfile.fromJson(data),
    );
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': kAccessTokenMinutes,
      },
    );
    final data = res.data ?? <String, dynamic>{};
    final access = data['accessToken'] as String? ?? data['token'] as String?;
    if (access == null || access.isEmpty) {
      throw const FormatException('Respons refresh tidak berisi token');
    }
    return AuthTokens(
      access: access,
      refresh: data['refreshToken'] as String? ?? refreshToken,
    );
  }
}
