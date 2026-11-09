import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Post {
  const Post({required this.id, required this.title, required this.body});
  final int id;
  final String title;
  final String body;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
  );
}

class PostRepository {
  PostRepository(this._dio);
  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    return (response.data ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map(Post.fromJson)
        .toList();
  }
}

final postRepositoryProvider = Provider(
  (ref) => PostRepository(
    Dio(
      BaseOptions(
        baseUrl: 'https://jsonplaceholder.typicode.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    ),
  ),
);

final postsProvider = FutureProvider<List<Post>>(
  (ref) => ref.watch(postRepositoryProvider).fetchPosts(),
);

void main() => runApp(const ProviderScope(child: Week4App()));

class Week4App extends StatelessWidget {
  const Week4App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Week 4 - REST API',
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    home: const PostsPage(),
  );
}

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Posts')),
      body: posts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Gagal memuat data: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Belum ada data'))
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) => ListTile(
                  leading: CircleAvatar(child: Text('${items[index].id}')),
                  title: Text(items[index].title),
                  subtitle: Text(items[index].body),
                ),
              ),
      ),
    );
  }
}
