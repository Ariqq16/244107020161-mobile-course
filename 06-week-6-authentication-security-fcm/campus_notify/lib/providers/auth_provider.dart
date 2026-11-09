import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_client.dart';
import '../data/api_errors.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';
import '../data/user_profile.dart';

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final dioProvider = Provider<Dio>((ref) {
  return buildApiClient(
    store: ref.watch(tokenStoreProvider),
    auth: ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).logout(),
  );
});

class AuthNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final store = ref.read(tokenStoreProvider);
    final access = await store.readAccess();
    if (access == null || access.isEmpty) return null;
    return store.readProfile();
  }

  Future<String?> login(String username, String password) async {
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .login(username: username, password: password);
      final store = ref.read(tokenStoreProvider);
      await store.saveTokens(
        access: result.tokens.access,
        refresh: result.tokens.refresh,
      );
      await store.saveProfile(result.profile);
      state = AsyncData(result.profile);
      return null;
    } catch (e) {
      return friendlyError(e);
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(null);
  }
}

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, UserProfile?>(AuthNotifier.new);

final meProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final res = await ref.watch(dioProvider).get<Map<String, dynamic>>('/auth/me');
  return UserProfile.fromJson(res.data ?? <String, dynamic>{});
});
