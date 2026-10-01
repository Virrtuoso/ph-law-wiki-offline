import 'package:sqflite/sqflite.dart';

/// Raw SQLite queries for the `notes` table.
class NoteLocalDataSource {
  NoteLocalDataSource._();

  static Future<List<Map<String, Object?>>> getAllNotes(Database db) {
    return db.query('notes', orderBy: 'updated_at DESC');
  }

  static Future<Map<String, Object?>?> getNoteForArticle(
    Database db,
    String articleId,
  ) async {
    final rows = await db.query(
      'notes',
      where: 'article_id = ?',
      whereArgs: [articleId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<void> upsertNote(Database db, Map<String, Object?> row) {
    return db.insert(
      'notes',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteNote(Database db, String articleId) {
    return db.delete('notes', where: 'article_id = ?', whereArgs: [articleId]);
  }
}
