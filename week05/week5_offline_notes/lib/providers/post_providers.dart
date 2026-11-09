import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/post.dart';
import '../data/repositories/post_repository.dart';
import 'offline_providers.dart';

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(),
);

final postsProvider = AsyncNotifierProvider<PostsNotifier, List<Post>>(
  PostsNotifier.new,
);

class PostsNotifier extends AsyncNotifier<List<Post>> {
  PostRepository get _repo => ref.read(postRepositoryProvider);

  @override
  Future<List<Post>> build() async {
    final cached = await _repo.readCachedPosts();
    if (ref.read(forceOfflineProvider)) return cached;

    try {
      return await _repo.fetchAndCache();
    } catch (_) {
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }

  Future<bool> refresh() async {
    if (ref.read(forceOfflineProvider)) return false;

    try {
      final posts = await _repo.fetchAndCache();
      state = AsyncData(posts);
      return true;
    } catch (_) {
      return false;
    }
  }
}
