import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Todo {
  const Todo(this.title, {this.done = false});
  final String title;
  final bool done;
  Todo copyWith({bool? done}) => Todo(title, done: done ?? this.done);
}

class TodoNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() => const [Todo('Pelajari GoRouter')];

  void add(String title) => state = [...state, Todo(title)];
  void toggle(int index) {
    final next = [...state];
    next[index] = next[index].copyWith(done: !next[index].done);
    state = next;
  }
}

final todoProvider = NotifierProvider<TodoNotifier, List<Todo>>(
  TodoNotifier.new,
);

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodoPage(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) =>
              DetailPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ],
);

void main() => runApp(const ProviderScope(child: Week3App()));

class Week3App extends StatelessWidget {
  const Week3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Week 3 - Navigation',
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
    );
  }
}

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('ToDo')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) => CheckboxListTile(
          value: todos[index].done,
          title: Text(todos[index].title),
          onChanged: (_) => ref.read(todoProvider.notifier).toggle(index),
          secondary: IconButton(
            tooltip: 'Buka detail',
            icon: const Icon(Icons.open_in_new),
            onPressed: () => context.go('/detail/$index'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(todoProvider.notifier).add('Tugas baru'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  const DetailPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Detail $id')),
    body: Center(child: Text('Anda membuka tugas dengan id: $id')),
  );
}
