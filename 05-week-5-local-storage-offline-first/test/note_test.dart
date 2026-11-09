import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/main.dart';

void main() {
  test('repository supports offline create and sync', () async {
    final repository = NotesRepository();
    await repository.add('Judul', 'Isi');
    final notes = await repository.read();
    expect(notes.single.dirty, isTrue);
    await repository.toggleSync(notes.single.id);
    expect((await repository.read()).single.dirty, isFalse);
  });
}
