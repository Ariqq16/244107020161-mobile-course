import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.dirty = true,
  });

  final int id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Note copyWith({String? title, String? body, bool? dirty}) => Note(
    id: id,
    title: title ?? this.title,
    body: body ?? this.body,
    updatedAt: DateTime.now(),
    dirty: dirty ?? this.dirty,
  );
}

class NotesRepository {
  final List<Note> _notes = [];
  int _nextId = 1;

  Future<List<Note>> read() async => List.unmodifiable(_notes);

  Future<void> add(String title, String body) async {
    _notes.insert(
      0,
      Note(id: _nextId++, title: title, body: body, updatedAt: DateTime.now()),
    );
  }

  Future<void> toggleSync(int id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index >= 0) _notes[index] = _notes[index].copyWith(dirty: false);
  }
}

final notesRepositoryProvider = Provider((ref) => NotesRepository());

final notesProvider = AsyncNotifierProvider<NotesNotifier, List<Note>>(
  NotesNotifier.new,
);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() => ref.watch(notesRepositoryProvider).read();

  Future<void> add(String title, String body) async {
    await ref.read(notesRepositoryProvider).add(title, body);
    ref.invalidateSelf();
  }

  Future<void> sync(Note note) async {
    await ref.read(notesRepositoryProvider).toggleSync(note.id);
    ref.invalidateSelf();
  }
}

void main() => runApp(const ProviderScope(child: Week5App()));

class Week5App extends StatelessWidget {
  const Week5App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Week 5 - Offline Notes',
    theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
    home: const NotesPage(),
  );
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Notes')),
      body: notes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal membaca catatan: $error')),
        data: (items) => items.isEmpty
            ? const Center(child: Text('Belum ada catatan'))
            : ListView(
                children: items
                    .map(
                      (note) => ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.body),
                        trailing: note.dirty
                            ? IconButton(
                                tooltip: 'Sinkronkan',
                                icon: const Icon(Icons.cloud_upload),
                                onPressed: () =>
                                    ref.read(notesProvider.notifier).sync(note),
                              )
                            : const Icon(Icons.cloud_done),
                      ),
                    )
                    .toList(),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(notesProvider.notifier)
            .add('Catatan baru', 'Dibuat saat offline'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
