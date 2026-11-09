import 'package:dio/dio.dart';

import '../config.dart';
import 'auth_repository.dart';
import 'token_store.dart';

Dio buildApiClient({
  required TokenStore store,
  required AuthRepository auth,
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
      final access = await store.readAccess();
      if (access != null && access.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $access';
      }
      handler.next(options);
    },
    onError: (error, handler) async {
      final request = error.requestOptions;
      final code = error.response?.statusCode;
      final alreadyRetried = request.extra['retried'] == true;

      if ((code == 401 || code == 403) && !alreadyRetried) {
        final refresh = await store.readRefresh();
        if (refresh == null || refresh.isEmpty) {
          await onSessionExpired();
          return handler.next(error);
        }

        AuthTokens tokens;
        try {
          tokens = await auth.refresh(refresh);
        } catch (_) {
          await onSessionExpired(); // refresh ikut kedaluwarsa -> login ulang
          return handler.next(error);
        }

        await store.saveTokens(access: tokens.access, refresh: tokens.refresh);
        request.extra['retried'] = true;
        request.headers['Authorization'] = 'Bearer ${tokens.access}';
        try {
          final retried = await dio.fetch<dynamic>(request);
          return handler.resolve(retried);
        } on DioException catch (e) {
          return handler.next(e);
        }
      }
      handler.next(error);
    },
  ));

  return dio;
}
