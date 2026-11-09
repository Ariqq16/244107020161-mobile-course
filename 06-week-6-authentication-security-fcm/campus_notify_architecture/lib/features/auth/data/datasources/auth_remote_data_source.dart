import 'package:dio/dio.dart';

import '../../../../core/config/app_config.dart';
import '../models/user_model.dart';

class RemoteAuthTokens {
  const RemoteAuthTokens({required this.access, required this.refresh});
  final String access;
  final String refresh;
}

class RemoteLoginData {
  const RemoteLoginData({
    required this.user,
    required this.tokens,
  });
  final UserModel user;
  final RemoteAuthTokens tokens;
}

class AuthRemoteDataSource {
  AuthRemoteDataSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: kApiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Accept': 'application/json'},
            ));

  final Dio _dio;

  Future<RemoteLoginData> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
        'expiresInMins': kAccessTokenMinutes,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final access = data['accessToken'] as String? ?? data['token'] as String?;
    final refresh = data['refreshToken'] as String? ?? '';
    if (access == null || access.isEmpty) {
      throw const FormatException('Respons login tidak berisi token');
    }
    return RemoteLoginData(
      user: UserModel.fromJson(data),
      tokens: RemoteAuthTokens(access: access, refresh: refresh),
    );
  }

  Future<RemoteAuthTokens> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {
        'refreshToken': refreshToken,
        'expiresInMins': kAccessTokenMinutes,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    final access = data['accessToken'] as String? ?? data['token'] as String?;
    if (access == null || access.isEmpty) {
      throw const FormatException('Respons refresh tidak berisi token');
    }
    return RemoteAuthTokens(
      access: access,
      refresh: data['refreshToken'] as String? ?? refreshToken,
    );
  }
}
