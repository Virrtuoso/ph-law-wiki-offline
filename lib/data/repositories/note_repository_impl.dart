import '../../domain/entities/note.dart';
import '../../domain/repositories/i_note_repository.dart';
import '../../infrastructure/database/database_helper.dart';
import '../../infrastructure/utils/id_generator.dart';
import '../datasources/note_local_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements INoteRepository {
  NoteRepositoryImpl({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  @override
  Future<List<Note>> getAllNotes() async {
    final db = await _databaseHelper.database;
    final rows = await NoteLocalDataSource.getAllNotes(db);
    return rows.map(NoteModel.fromMap).toList();
  }

  @override
  Future<Note?> getNoteForArticle(String articleId) async {
    final db = await _databaseHelper.database;
    final row = await NoteLocalDataSource.getNoteForArticle(db, articleId);
    return row == null ? null : NoteModel.fromMap(row);
  }

  @override
  Future<void> saveNote(String articleId, String noteText) async {
    final db = await _databaseHelper.database;
    final existing = await NoteLocalDataSource.getNoteForArticle(
      db,
      articleId,
    );
    final now = DateTime.now().toIso8601String();
    final note = Note(
      id: existing != null ? existing['id'] as String : IdGenerator.newId(),
      articleId: articleId,
      noteText: noteText,
      createdAt: existing != null ? existing['created_at'] as String : now,
      updatedAt: now,
    );
    await NoteLocalDataSource.upsertNote(db, NoteModel.toMap(note));
  }

  @override
  Future<void> deleteNote(String articleId) async {
    final db = await _databaseHelper.database;
    await NoteLocalDataSource.deleteNote(db, articleId);
  }
}
