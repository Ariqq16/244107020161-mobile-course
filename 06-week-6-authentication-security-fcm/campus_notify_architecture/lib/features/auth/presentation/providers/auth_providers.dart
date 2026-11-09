import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/friendly_error.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/authenticated_api_client.dart';
import '../../data/datasources/token_local_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login.dart';
import '../../domain/usecases/logout.dart';

final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(),
);
final tokenLocalDataSourceProvider = Provider(
  (ref) => TokenLocalDataSource(),
);
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(tokenLocalDataSourceProvider),
  );
});
final loginUseCaseProvider = Provider(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);
final logoutUseCaseProvider = Provider(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() => ref.read(authRepositoryProvider).restoreSession();

  Future<String?> login(String username, String password) async {
    try {
      final session = await ref.read(loginUseCaseProvider)(
        username: username,
        password: password,
      );
      state = AsyncData(session.user);
      return null;
    } catch (error) {
      return friendlyError(error);
    }
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider)();
    state = const AsyncData(null);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, User?>(AuthNotifier.new);

/// Protected Dio client: the API layer depends on domain repository contract,
/// not on a concrete auth implementation.
final authenticatedApiClientProvider = Provider<AuthenticatedApiClient>((ref) {
  return buildAuthenticatedApiClient(
    repository: ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).logout(),
  );
});

final meProvider = FutureProvider.autoDispose<User>((ref) {
  return ref.watch(authenticatedApiClientProvider).getCurrentUser();
});
