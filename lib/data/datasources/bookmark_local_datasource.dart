import 'package:sqflite/sqflite.dart';

/// Raw SQLite queries for the `bookmarks` table.
class BookmarkLocalDataSource {
  BookmarkLocalDataSource._();

  static Future<List<Map<String, Object?>>> getAllBookmarks(Database db) {
    return db.query('bookmarks', orderBy: 'created_at DESC');
  }

  static Future<Map<String, Object?>?> getBookmarkForArticle(
    Database db,
    String articleId,
  ) async {
    final rows = await db.query(
      'bookmarks',
      where: 'article_id = ?',
      whereArgs: [articleId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  static Future<void> insertBookmark(Database db, Map<String, Object?> row) {
    return db.insert(
      'bookmarks',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteBookmark(Database db, String articleId) {
    return db.delete(
      'bookmarks',
      where: 'article_id = ?',
      whereArgs: [articleId],
    );
  }
}
