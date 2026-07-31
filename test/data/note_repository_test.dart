import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:ph_law_wiki_offline/data/repositories/note_repository_impl.dart';
import 'package:ph_law_wiki_offline/infrastructure/database/database_helper.dart';
import 'package:ph_law_wiki_offline/infrastructure/seed/seed_data.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late DatabaseHelper dbHelper;
  late NoteRepositoryImpl repository;

  setUp(() async {
    dbHelper = DatabaseHelper.forTesting(
      testDatabaseName: inMemoryDatabasePath,
    );
    final db = await dbHelper.database;
    await SeedData.seedIfNeeded(db);
    repository = NoteRepositoryImpl(databaseHelper: dbHelper);
  });

  tearDown(() async {
    await dbHelper.close();
  });

  group('NoteRepositoryImpl', () {
    test('a fresh article has no note', () async {
      expect(await repository.getNoteForArticle('cc-art-37'), isNull);
    });

    test('saveNote creates a note that can be retrieved', () async {
      await repository.saveNote('cc-art-37', 'Remember: applies from birth.');
      final note = await repository.getNoteForArticle('cc-art-37');
      expect(note, isNotNull);
      expect(note!.noteText, 'Remember: applies from birth.');
      expect(note.articleId, 'cc-art-37');
    });

    test('saveNote on an existing note updates its text', () async {
      await repository.saveNote('cc-art-37', 'First draft.');
      final firstNote = await repository.getNoteForArticle('cc-art-37');

      await repository.saveNote('cc-art-37', 'Revised note text.');
      final updatedNote = await repository.getNoteForArticle('cc-art-37');

      expect(updatedNote!.noteText, 'Revised note text.');
      expect(updatedNote.id, firstNote!.id);

      final all = await repository.getAllNotes();
      expect(all.length, 1);
    });

    test('deleteNote removes the note', () async {
      await repository.saveNote('cc-art-37', 'Temporary note.');
      await repository.deleteNote('cc-art-37');
      expect(await repository.getNoteForArticle('cc-art-37'), isNull);
      expect(await repository.getAllNotes(), isEmpty);
    });

    test('getAllNotes returns notes across multiple articles', () async {
      await repository.saveNote('cc-art-37', 'Note A');
      await repository.saveNote('const-preamble', 'Note B');
      final all = await repository.getAllNotes();
      expect(all.length, 2);
      expect(all.map((n) => n.articleId).toSet(), {
        'cc-art-37',
        'const-preamble',
      });
    });
  });
}
