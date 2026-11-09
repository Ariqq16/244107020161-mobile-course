import 'package:dio/dio.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user.dart';
import '../../../../core/config/app_config.dart';

class AuthenticatedApiClient {
  AuthenticatedApiClient(this._dio);
  final Dio _dio;

  Future<User> getCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    final data = response.data ?? <String, dynamic>{};
    return User(
      id: (data['id'] as num?)?.toInt() ?? 0,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      image: data['image'] as String?,
    );
  }
}

AuthenticatedApiClient buildAuthenticatedApiClient({
  required AuthRepository repository,
  required Future<void> Function() onSessionExpired,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: kApiBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Accept': 'application/json'},
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await repository.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      final code = error.response?.statusCode;
      final request = error.requestOptions;
      if ((code == 401 || code == 403) && request.extra['retried'] != true) {
        final refreshToken = await repository.readRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await onSessionExpired();
          return handler.next(error);
        }
        try {
          final tokens = await repository.refresh(refreshToken);
          request.extra['retried'] = true;
          request.headers['Authorization'] = 'Bearer ${tokens.access}';
          final response = await dio.fetch<dynamic>(request);
          return handler.resolve(response);
        } catch (_) {
          await onSessionExpired();
          return handler.next(error);
        }
      }
      handler.next(error);
    },
  ));
  return AuthenticatedApiClient(dio);
}
